{ ... }:

{
  services.jitsi-meet = {
    enable = false;
    hostName = "jitsi.ozguryazilimhacettepe.com";
    # chromedriver is not available for aarch64-linux.
    # jibri.enable = true;
  };
}
