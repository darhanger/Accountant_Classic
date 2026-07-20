<!-- markdownlint-disable MD004 MD033 -->

<div align="center">

**English** | [Русский](README_RU.md)

# Accountant Classic

![Lua 5.1](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat-square&logo=lua&logoColor=white)
![WoW 3.3.5a](https://img.shields.io/badge/WoW-3.3.5a-C79C6E?style=flat-square)
[![License](https://img.shields.io/github/license/darhanger/Accountant_Classic?style=flat-square)](https://github.com/darhanger/Accountant_Classic/blob/master/LICENSE)
[![Last Release](https://img.shields.io/github/v/release/darhanger/Accountant_Classic?style=flat-square)](https://github.com/darhanger/Accountant_Classic/releases/latest)
[![Release Downloads](https://img.shields.io/github/downloads/darhanger/Accountant_Classic/2.6.0/total?style=flat-square)](https://github.com/darhanger/Accountant_Classic/releases/tag/2.6.0)
[![All Downloads](https://img.shields.io/github/downloads/darhanger/Accountant_Classic/total?style=flat-square)](https://github.com/darhanger/Accountant_Classic/releases)
[![Discord Server](https://img.shields.io/badge/Discord-7289DA?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/ZKFkvrzaU4)

**Accountant Classic** is a lightweight economy tracker that records where your money comes from and where it goes.

It provides separate income and expense statistics for the current session, day, week and the entire tracking period.

Designed for **World of Warcraft 3.3.5a**.

</div>

## Features

Accountant Classic automatically watches changes to the player's money and assigns them to the activity that caused the transaction.

The addon provides:

- automatic tracking of income and expenses;
- separate incoming and outgoing totals for every category;
- session, daily, weekly and lifetime statistics;
- net profit or net loss calculation;
- total current money for characters on the same realm;
- automatic daily and weekly rollover;
- configurable first day of the week;
- reset controls for the selected report period;
- a movable Blizzard-style report window;
- a minimap launcher with adjustable position;
- a configurable key binding;
- LibDataBroker launcher support;
- optional Titan Panel refresh support;
- saved statistics and settings between sessions.

## Tracked categories

Money changes are divided into the following categories:

| Category | Examples |
| --- | --- |
| Training | Class trainers and profession training |
| Taxi | Flight path expenses |
| Trade | Direct player-to-player trades |
| Auction House | Auction purchases, deposits and sales |
| Merchants | Buying and selling items to vendors |
| Repairs | Personal equipment repair costs |
| Mail | Money sent or received through mail |
| Quests | Quest rewards and related transactions |
| Loot | Money looted from creatures and shared loot |
| Other | Transactions that cannot be assigned to another category |

Income and expenses are stored separately for each category.

## Report periods

The main window contains five tabs:

### Session

Shows money earned and spent since the current login session began.

Session values are reset whenever the addon is loaded for a new session.

### Day

Shows the current day's income and expenses.

Daily values are reset automatically when the calendar day changes.

### Week

Shows statistics for the current configured week.

The first day of the week can be selected in the addon settings.

### Total

Shows all income and expenses recorded for the current character since tracking began or since the total report was manually reset.

### All characters

Shows the current money held by characters saved on the same realm, together with the date of their latest recorded update.

The tab also calculates the combined money total for those characters.

## Main window

The Accountant Classic window displays:

- transaction source;
- incoming money;
- outgoing money;
- total income;
- total expenses;
- net profit or net loss;
- current character money;
- the start date of the active week;
- current money totals for other characters on the same realm.

The window can be moved by dragging it with the left mouse button.

## Opening Accountant Classic

The report window can be opened in several ways:

- left-click the minimap button;
- use `/accountant`;
- use `/acc`;
- assign the **Accountant** action in the WoW key binding menu;
- left-click the Accountant Classic icon in a LibDataBroker display.

Right-clicking the minimap or LibDataBroker button opens the addon settings.

## Minimap button

The minimap launcher can be enabled or disabled in the settings.

Its position around the minimap can be changed with a slider and is saved separately for the character.

Button actions:

| Action | Result |
| --- | --- |
| Left click | Open or close the Accountant Classic window |
| Right click | Open the addon settings |
| Mouse hover | Show a short addon tooltip |

## Settings

Accountant Classic adds a category to the standard Blizzard Interface Options.

Available settings include:

- show or hide the minimap button;
- change the minimap button position;
- select the first day of the week.

All options are saved between game sessions.

## Slash commands

Both `/accountant` and `/acc` are supported.

| Command | Description |
| --- | --- |
| `/accountant` | Open the Accountant Classic window |
| `/acc` | Open the Accountant Classic window |
| `/accountant log` | Open the Accountant Classic window |
| `/accountant verbose` | Toggle diagnostic transaction messages |
| `/accountant week` | Print the calculated start date of the current week |

The `verbose` and `week` commands are mainly useful for testing and debugging.

## Resetting statistics

The **Reset** button clears the currently selected report period for the active character.

For example:

- reset only the current session;
- reset the current day;
- reset the current week;
- reset all recorded totals.

A confirmation dialog is displayed before data is deleted.

The **All characters** tab cannot be reset through this button.

## Installation

1. Download the latest version from the [Releases](https://github.com/darhanger/Accountant_Classic/releases) page.
2. Extract the downloaded archive.
3. Copy the `Accountant_Classic` folder into:

```text
World of Warcraft\Interface\AddOns\
```

4. Make sure the resulting folder structure looks similar to:

```text
World of Warcraft
└── Interface
    └── AddOns
        └── Accountant_Classic
            ├── Accountant_Classic.toc
            ├── Accountant.lua
            ├── Accountant.xml
            ├── AccountantButton.lua
            ├── AccountantButton.xml
            ├── AccountantOptions.lua
            ├── AccountantOptions.xml
            ├── Bindings.xml
            ├── Images
            ├── Libs
            └── Locale
```

5. Restart the game client.
6. Enable **Accountant Classic** in the character selection addon list.

## Usage

After installation, Accountant Classic starts tracking money automatically.

A typical workflow:

1. Play normally and earn or spend money.
2. Open Accountant Classic using the minimap button or `/acc`.
3. Select the desired report period.
4. Compare income and expenses by source.
5. Check the final net profit or net loss.
6. Open the **All characters** tab to see the combined money stored on the current realm.

No manual transaction entry is required.

## Saved data

Accountant Classic stores statistics by:

- realm;
- character;
- transaction category;
- report period.

The addon uses saved variables to preserve totals and settings between sessions.

Before reinstalling the game or deleting the WTF folder, back up the following file if you want to keep your history:

```text
WTF\Account\<ACCOUNT_NAME>\SavedVariables\Accountant_Classic.lua
```

The exact account folder name depends on the game installation.

## Localization

The addon includes built-in localization for:

- English
- French
- German
- Korean
- Russian
- Simplified Chinese
- Traditional Chinese

## Included libraries

Required libraries are bundled with the addon:

- LibStub
- CallbackHandler-1.0
- LibAboutPanel
- LibDataBroker-1.1

They do not need to be installed separately.

## Compatibility

- World of Warcraft **3.3.5a**
- Interface version **30300**
- Lua **5.1**
- Standard Blizzard money and UI events
- Standard Blizzard Interface Options
- LibDataBroker displays
- Optional Titan Panel interaction

Behavior may differ on heavily modified custom clients if money events, auction behavior or localized money messages do not match the original 3.3.5a client.

## Known limitations

Accountant Classic determines the source of a transaction from the game window or activity active when the money changes.

A transaction may be recorded under **Other** when:

- the client does not report the expected event;
- several money changes happen in an unusual order;
- a custom server changes the normal transaction flow;
- another addon or custom system modifies money without opening a standard Blizzard window.

The **All characters** tab contains only characters from the same realm that have previously loaded the addon.

## Why use Accountant Classic?

Accountant Classic can help you:

- understand where your gold is being spent;
- compare questing, farming and auction income;
- monitor repair and travel expenses;
- calculate profit during a farming session;
- review daily and weekly gold flow;
- see the combined money stored across characters;
- test economy changes on custom WoW servers;
- verify transaction behavior during addon or server development.

## Support

For bug reports, feature requests and suggestions, use:

- [GitHub Issues](https://github.com/darhanger/Accountant_Classic/issues)

When reporting an incorrect transaction, include:

- the game client or server name;
- the Accountant Classic version;
- the transaction type;
- the amount gained or spent;
- the category where it was recorded;
- the category where it should have been recorded;
- steps required to reproduce the problem;
- Lua error text, when available.

## Credits

Based on **Accountant Classic**.

World of Warcraft 3.3.5a adaptation and maintenance by **DarhangeR**.

## Contributing

Contributions are welcome.

You can help by:

- reporting incorrectly categorized transactions;
- testing the addon on different 3.3.5a servers;
- improving localization;
- fixing compatibility issues;
- improving documentation;
- submitting pull requests.

## License

This project is distributed under the terms of the [MIT License](https://github.com/darhanger/Accountant_Classic/blob/master/LICENSE).

---

<div align="center">

Made for World of Warcraft 3.3.5a

[Download](https://github.com/darhanger/Accountant_Classic/releases) ·
[Report an issue](https://github.com/darhanger/Accountant_Classic/issues) ·
[Discord](https://discord.gg/ZKFkvrzaU4)

</div>