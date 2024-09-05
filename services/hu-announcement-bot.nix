{ config, pkgs, ... }: 
{
  services.hu-announcement-bot = {
    enable = true;
    hostname = "huannouncementbot.ozguryazilimhacettepe.com";
    environmentFile = config.age.secrets.hu-announcement-bot.path;

    settings = {
      # Setted in environmentFile.
      TELEGRAM_API_KEY = "$TELEGRAM_API_KEY";
      DB_STRING = "$DB_STRING";
      DB_NAME = "hu-announcement-db";

      FEEDBACK_CHAT_ID = -762965708;
      ADMIN_ID = 734839772;
      LOGGER_CHAT_ID = -874312282;

      DEFAULT_DEPS = [ "hu-sksdb" "hu-oidb" ];
    };
  };

  age.secrets = {
    hu-announcement-bot = {
      file = ../secrets/services/hu-announcement-bot.age;
    };
  };
}
