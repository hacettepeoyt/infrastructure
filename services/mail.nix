{ config, options, pkgs, ... }:

let
  domain = "mail.ozguryazilimhacettepe.com";

  mailpot = pkgs.rustPlatform.buildRustPackage rec {
    pname = "mailpot";
    version = "0.1.1+git";

    src = pkgs.fetchFromGitHub {
      owner = "meli";
      repo = "mailpot";
      rev = "3366e3b12e287edfa78a4fe62dba06db0005ca73";
      hash = "sha256-cS9xCKOnOi5eOYgdVTNp0EEtRzEMr2K1Myb80Kmskfw=";
    };

    cargoHash = "sha256-q7sCSGU8xp81Fqpx8zn2zyk16IFaBVuOxSpxtSB92Sg=";

    buildInputs = [ pkgs.openssl ];
    nativeBuildInputs = [ pkgs.pkg-config ];
    nativeCheckInputs = [ pkgs.openssh pkgs.sqlite ];
  };

  mailpotConf = pkgs.writeText "mailpot.toml" ''
    db_path = "/var/lib/mailpot/mailpot.sqlite"
    data_path = "/var/lib/mailpot"

    [send_mail]
    type = "Smtp"
    value = { hostname = "localhost", port = 2525, auth = { type = "None" } }
  '';
in
{
  services.nginx.virtualHosts."${domain}".enableACME = true;
  security.acme.certs."${domain}".group = "maddy";
  users.groups."maddy" = {
    members = [ "maddy" "nginx" ];
  };

  # TODO: I'd much prefer PAM authentication here, but I could not get it to work.
  networking.firewall.allowedTCPPorts = [ 993 465 ];
  services.maddy = {
    enable = true;
    openFirewall = true;

    tls = {
      loader = "file";
      certificates = [
        {
          certPath = "${config.security.acme.certs.${domain}.directory}/cert.pem";
          keyPath = "${config.security.acme.certs.${domain}.directory}/key.pem";
        }
      ];
    };

    hostname = domain;
    primaryDomain = "ozguryazilimhacettepe.com";
    localDomains = [ "ozguryazilimhacettepe.com" "lists.tlkg.org.tr" ];
    config = ''
      auth.pass_table local_authdb {
          table sql_table {
              driver sqlite3
              dsn credentials.db
              table_name passwords
          }
      }

      storage.imapsql local_mailboxes {
        driver sqlite3
        dsn imapsql.db
      }

      table.chain local_rewrites {
        optional_step regexp "(.+)\+(.+)@(.+)" "$1@$3"
        optional_step static {
            entry postmaster postmaster@$(primary_domain)
        }
        optional_step file /etc/maddy/aliases
      }

      msgpipeline local_routing {
          # Insert handling for special-purpose local domains here.
          # e.g.
          # destination lists.example.org {
          #     deliver_to lmtp tcp://127.0.0.1:8024
          # }

          destination lists.tlkg.org.tr {
              check {
                  command ${mailpot}/bin/mpot -q -c "${mailpotConf}" post
              }

              deliver_to dummy
          }

          destination postmaster $(local_domains) {
              modify {
                  replace_rcpt &local_rewrites
              }

              deliver_to &local_mailboxes
          }

          default_destination {
              reject 550 5.1.1 "User doesn't exist"
          }
      }

      smtp tcp://0.0.0.0:25 {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections.
              all rate 20 1s
              all concurrency 10
          }

          dmarc yes
          check {
              require_mx_record
              dkim
              spf
          }

          source $(local_domains) {
              reject 501 5.1.8 "Use Submission for outgoing SMTP"
          }
          default_source {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.1.1 "User doesn't exist"
              }
          }
      }

      smtp tcp://127.0.0.1:2525 {
        destination postmaster $(local_domains) {
            deliver_to &local_routing
        }

        default_destination {
            deliver_to &remote_queue
        }
      }

      submission tls://0.0.0.0:465 tcp://0.0.0.0:587 {
          limits {
              # Up to 50 msgs/sec across any amount of SMTP connections.
              all rate 50 1s
          }

          auth &local_authdb

          source $(local_domains) {
              check {
                  authorize_sender {
                      prepare_email &local_rewrites
                      user_to_email identity
                  }
              }

              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  modify {
                      dkim $(primary_domain) $(local_domains) default
                  }
                  deliver_to &remote_queue
              }
          }
          default_source {
              reject 501 5.1.8 "Non-local sender domain"
          }
      }

      target.remote outbound_delivery {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections
              # for each recipient domain.
              destination rate 20 1s
              destination concurrency 10
          }
          mx_auth {
              dane
              mtasts {
                  cache fs
                  fs_dir mtasts_cache/
              }
              local_policy {
                  min_tls_level encrypted
                  min_mx_level none
              }
          }
      }

      target.queue remote_queue {
          target &outbound_delivery

          autogenerated_msg_domain $(primary_domain)
          bounce {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.0.0 "Refusing to send DSNs to non-local addresses"
              }
          }
      }

      # ----------------------------------------------------------------------------
      # IMAP endpoints

      imap tls://0.0.0.0:993 tcp://0.0.0.0:143 {
          auth &local_authdb
          storage &local_mailboxes
      }
  '';
  };

  # FIXME: temp
  environment.systemPackages = [ pkgs.sqlite ];
  users.users.mailpot = {
    isSystemUser = true;
    home = "/var/lib/mailpot";
    createHome = true;
    homeMode = "770";
    group = "maddy";
  };
}
