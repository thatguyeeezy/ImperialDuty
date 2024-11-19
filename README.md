# ImperialDuty Script

The **ImperialDuty** script is designed to manage duty statuses and equipment within the game. This script allows users to toggle their on-duty status with a simple `/duty` command, automatically integrating this status into the **Imperial911** script. It also equips users with predefined weapons configured within the script settings, enhancing the gameplay experience for role-play scenarios.

---

## Features

- **Duty Status Toggle**: Allows users to switch their on-duty status with a single command, updating their status across relevant scripts.
- **Automatic Weapon Assignment**: Configures and equips users with weapons specified in the `main.lua` under the shared folder, ready upon entering duty.

## Commands

| Command   | Description                                                                          |
|-----------|--------------------------------------------------------------------------------------|
| `/duty`   | Toggles the user’s duty status and equips them with predefined weapons.              |

---

## Installation

To install the **ImperialDuty** script, follow these detailed steps:

1. **Download the Script Files**  
   Download the latest release from the repository.

2. **Add to Your Server Resources**  
   Place the `ImperialDuty` folder into your server's resources directory.

3. **Community ID Configuration**  
   Set up a `community ID` to ensure all Imperial scripts interact seamlessly:
   - Locate your community ID in *Admin Panel > Customization > Community ID*.
   - Add the following line at the top of your `server.cfg` file:
     ```plaintext
     setr imperial_community_id "COMMUNITY_ID_HERE"
     ```
   - If this is your first Imperial script installation, this step is crucial.

4. **Ensure Resources in `server.cfg`**  
   Add the following line to your `server.cfg` to make sure the *ImperialDuty* script loads correctly:
   ```plaintext
   ensure ImperialDuty
   ```

5. **Restart Your Server**  
   Restart your server to enable the changes.

---

## Requirements

- **Imperial CAD**: This script requires an active *Imperial CAD* system to function effectively.
- **Weapon Configuration**: Ensure weapons are correctly configured in `main.lua` under the shared folder prior to enabling the script.

## Usage Notes

After installation, users can toggle their on-duty status by using the `/duty` command. This command will equip them with the weapons specified in the configuration file. It's important to check and update weapon configurations as needed to fit the server's role-play settings.

---

### License

This script is owned by *Imperial Solutions*. Unauthorized copying, distribution, or use of this script without explicit permission is prohibited and may lead to legal repercussions.

---

For additional support, please visit the *Imperial Solutions* [Support Discord](https://discord.gg/N5UJBSDdsn) or consult our support channels.
