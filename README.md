# TTR Updates Bot

A bot that notifies you upon the release of updates to Toontown Rewritten, and uploads the extracted changes to [ttr_update_files](https://github.com/CoocooFroggy/ttr_update_files).

![Screenshot of TTR Updates Bot being used in Discord](assets/SCR-20230916-ntxl.png)

## Permissions

- `applications.commands`
- `bot`
  - Send Messages
  - Mention Everyone

## Environment variables
- `TOKEN`: Discord bot token
- `DB_URL`: MongoDB URL (mongodb+srv://username:password@url/database)
- `DEBUG`: If set, will not ignore exceptions and will end execution
- `GH_TOKEN`: GitHub token used to push to [ttr_update_files](https://github.com/CoocooFroggy/ttr_update_files)
