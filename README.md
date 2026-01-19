Ruby Platformer (Early Development)
This is a small but growing 2D platformer built with Ruby and the Gosu library. The goal of the project is to create a simple, moddable platformer engine with clean movement, stable physics, and fully customizable maps. The project is still in very early development, so expect missing features, rough edges, and ongoing changes.

FEATURES (SO FAR)
• 	Smooth platformer movement
• 	Pixel-step collision for stable physics
• 	Double-jump powerups
• 	Checkpoints and respawning
• 	Collectible stars
• 	Basic animation system
• 	Camera that follows the player
• 	User-created maps (see below)

CREATING YOUR OWN MAPS
Maps are created using simple text files.
Each character in the file represents a tile in the world.
You can open any text editor (Notepad, VSCode, etc.) and build levels by typing characters.

TILE LEGEND (CURRENT ENGINE)
.   = Empty air
= Wall block
1   = Wall block (variant 1)
2   = Wall block (variant 2)
3   = Wall block (variant 3)
• 	= Star collectible
C   = Checkpoint
D   = Double‑jump powerup
V   = Victory flag / goal
(You can add more tile types later as the engine grows.)

HOW TO MAKE A MAP
1. 	Create a new text file (example: level1.txt)
2. 	Fill it with rows of characters using the tile legend above
3. 	Save the file in the game's maps folder
4. 	Run the game
5. 	The engine loads your map and converts it into a playable level
Example:
####################
#.................V#
#.........22...*...#
#.....111..........#
#..C...........*...#
#..1.......3.......#
####################
This creates:
• 	Solid walls (#, 1, 2, 3)
• 	A star (*)
• 	A checkpoint (C)
• 	A victory flag (V)
• 	Open space (.)

EARLY DEVELOPMENT NOTICE
This project is still very early in development. Physics, tile rules, map formats, and features may change. Bugs are expected. Code is being refactored often.
Any help, feedback, or contributions would be greatly appreciated.

CONTRIBUTING
If you want to help improve the project, feel free to:
• 	Fix bugs
• 	Improve physics
• 	Add new tile types
• 	Expand the map system
• 	Create art
• 	Suggest features
• 	Clean up code
• 	Write documentation
Pull requests and ideas are welcome.


REQUIREMENTS
• 	Ruby
• 	Gosu gem
Install Gosu: gem install gosu
Run the game: ruby main.rb
• 	Gosu gem
Install Gosu: gem install gosu
Run the game: ruby main.rb
