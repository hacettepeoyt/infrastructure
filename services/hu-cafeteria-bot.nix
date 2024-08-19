{ config, pkgs, ... }:
{
  services.hu-cafeteria-bot = {
    enable = true;
    hostname = "hucafeteriabot.ozguryazilimhacettepe.com";
    environmentFile = config.age.secrets.hu-cafeteria-bot.path;

    settings = {
      # Setted in environmentFile.
      TELEGRAM_API_KEY = "$TELEGRAM_API_KEY";

      IMAGE_CHANNEL_ID = -1001534922038;
      TEXT_CHANNEL_ID = -1001815648235;
      LOGGER_CHAT_ID = -874312282;

      SMTP_HOST = "ozguryazilimhacettepe.com";
      SMTP_USERNAME = "hucafeteriabot@ozguryazilimhacettepe.com";
      SMTP_PASSWORD = "$SMTP_PASSWORD";
      # TODO: Make an actual mailing list.
      MAILING_LIST_ADDRESS = "hucafeteriabot@div72.xyz";
    };
  };

  services.maddy.ensureCredentials."hucafeteriabot@ozguryazilimhacettepe.com".passwordFile = config.age.secrets.hu-cafeteria-bot-email.path;

  age.secrets = {
    hu-cafeteria-bot = {
      file = ../secrets/services/hu-cafeteria-bot.age;
      owner = "hu-cafeteria-bot";
    };
    hu-cafeteria-bot-email = {
      file = ../secrets/services/hu-cafeteria-bot-email.age;
      owner = "maddy";
    };
  };
}
