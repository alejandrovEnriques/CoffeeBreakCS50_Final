# Coffee Break

#### Video Demo: https://youtu.be/N5JXtMbuV_I

#### Description:

Coffee Break is a fast-paced arcade game inspired by classic lane-management games such as Tapper. The player takes the role of a barista working in a busy coffee shop, serving customers before they become impatient. The objective is simple: keep customers happy, earn as many tips as possible, and survive as long as possible while the difficulty gradually increases.

The project was developed in Lua using the LÖVE2D framework as my final project for Harvard's CS50 course. I wanted to create a complete game experience rather than a simple programming demonstration. My goal was to build a small but polished arcade game that could be played both on PC and Android devices.

The gameplay takes place across four lanes. Customers enter the coffee shop from the right side of the screen and move toward the counter. The player controls a barista who can move between lanes and serve coffee to waiting customers. Once served, customers drink their coffee and leave, rewarding the player with tips. As more customers are successfully served, the game becomes faster and more challenging.

The game contains several failure conditions. The player can lose by allowing a customer to reach the counter without being served, by throwing coffee into an empty lane, or by failing to catch an empty cup returning from a customer. These mechanics were inspired by classic arcade design philosophies, where players must constantly balance speed, precision, and attention.

One of the main features of the game is its difficulty progression system. Rather than keeping a constant pace, Coffee Break gradually increases customer speed and spawn rates over time. This creates a natural difficulty curve that allows new players to learn the mechanics while still providing a challenge for experienced players. During development, multiple playtests were conducted to adjust the pacing and ensure the game remained fair while becoming increasingly intense.

The project is organized into several Lua files, each with a specific responsibility. The main game loop and overall state management are handled by main.lua. Customer behavior, movement, and interactions are managed in customers.lua. The player character and movement logic are contained in character.lua. Difficulty progression is controlled by difficulty.lua. Score tracking and game statistics are handled by scores.lua, while persistent save functionality is managed through save.lua.

Another important design goal was mobile compatibility. While the project originally began with keyboard controls, it was later adapted to support touch controls. The player can tap a lane to move the barista and use an on-screen serve button to interact with customers. Supporting both desktop and mobile platforms required significant changes to the input system and user interface.

Throughout development, I encountered several challenges. One of the most difficult aspects was balancing the game's difficulty curve. Early versions were either too easy or became overwhelming too quickly. Another challenge was implementing a pause system that worked correctly across both desktop and mobile platforms. Testing on Android devices also revealed additional issues related to touch controls and screen layouts that required several iterations to resolve.

Although the current version is fully playable, there are many ideas that could be explored in future updates. Potential improvements include additional customer types, new visual effects, expanded scoring systems, online leaderboards, more music tracks, and a larger variety of coffee shop environments. I would also like to further develop the game's presentation through additional artwork and animations.

Overall, Coffee Break represents the combination of many concepts learned throughout CS50, including game logic, state management, user interaction, file organization, and problem solving. More importantly, it allowed me to create a complete game from concept to final release while applying programming principles in a practical and creative project.

File Structure

The project is divided into multiple Lua files to keep the code organized and easier to maintain. The main.lua file contains the main game loop, state management, drawing logic, and initialization of the game. character.lua handles the player's movement and interactions. customers.lua manages customer spawning, movement, states, and customer-related gameplay logic. difficulty.lua controls the progression of difficulty over time, including spawn rates and movement speeds. save.lua is responsible for saving persistent data such as high scores. scores.lua manages score calculations, multipliers, and statistics shown to the player.

Design Decisions

One of the most important design decisions was choosing a lane-based gameplay structure inspired by classic arcade games. This allowed the controls to remain simple while still creating increasing difficulty as more customers appeared. Another important decision was supporting both desktop and mobile devices. This required redesigning the input system so that the game could be controlled with either a keyboard or touch controls.

Development Process

Development began with a simple prototype that only allowed customers to move across the screen. Additional mechanics were added incrementally, including customer states, score tracking, failure conditions, pause functionality, mobile controls, and difficulty progression. Multiple playtesting sessions were conducted with friends and family members to evaluate the game's pacing and difficulty curve. Feedback from these sessions was used to rebalance movement speeds, customer spawn timing, and scoring systems.

Challenges

Several technical challenges were encountered during development. One challenge was creating a difficulty system that gradually increased tension without overwhelming new players too quickly. Another challenge was implementing mobile controls that felt responsive while maintaining the same gameplay experience available on desktop systems. Additional work was required to ensure menus, pause screens, and game over screens behaved consistently across platforms.

Future Improvements

Although the project is complete for the purposes of CS50, there are many possible improvements. Future versions could include additional customer types, new environments, animations, sound effects, online leaderboards, achievements, expanded progression systems, and more visual polish. Additional accessibility options and customization settings could also improve the player experience.
