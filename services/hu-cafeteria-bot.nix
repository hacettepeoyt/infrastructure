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
    };
  };
}
