# Soccer Team Manager App

A mobile application designed to help coaches manage youth soccer teams during games, with a focus on fair play time distribution and easy substitution management.

## Core Features

### Team Management
- Maintain a persistent roster of players (stored locally)
  - Add new players with:
    - Name
    - Player number
  - Remove players from roster
  - Edit player information
  - Data persists between app sessions

### Game Setup
- Create named game sessions
- Select participating players from main roster for each game
- Configure number of periods for the game
- Visual formation setup using drag-and-drop interface
  - 7v7 format with fixed 2-3-1 formation
  - Visual representation of team's side of the field
  - Drag players from game roster to field positions
  - Position tracking for each player
  - Remaining players automatically marked as substitutes

### Game Time Management
- Track active game time with simple game clock display
- Support game pausing (injuries, half-time, etc.)
- Monitor individual statistics:
  - Playing time per player (displayed as MM:SS)
  - Bench time per player (displayed as MM:SS)
- Visual time indicators with numerical values:
  - Green: Less than 10 minutes of play time
  - Yellow: 10-20 minutes of play time
  - Orange: 20-30 minutes of play time
  - Red: Over 30 minutes of play time
  - For bench time:
    - Green: 0-5 minutes on bench
    - Yellow: 5-10 minutes on bench
    - Orange: 10-15 minutes on bench
    - Red: Over 15 minutes on bench

### Substitution Management
- Drag-and-drop interface for substitutions
- Position information displayed during substitutions
- Automatic time tracking updates when substitutions occur
- Seamless player swapping between field and bench

### Game History
- Save completed game data locally (maximum 12 games)
- Ability to clear historical game data
- Per game statistics:
  - Total play time per player
  - Total bench time per player
  - Number of substitutions
  - Game duration
  - Final formation snapshot

## Technical Implementation

### Platform and Framework Options
1. Cross-platform options:
   - React Native
     - Pros: Large community, native performance, code reuse
     - Cons: More complex native module integration
   - Flutter
     - Pros: Single codebase, excellent performance, great UI capabilities
     - Cons: Smaller community than React Native

2. Local Storage Options:
   - SQLite: For structured player and game data
   - AsyncStorage/SharedPreferences: For app settings
   - File storage: For game snapshots

3. State Management Requirements:
   - Real-time timer updates
   - Player position tracking
   - Game state management
   - Persistent data handling

4. Key Technical Requirements:
   - Drag and drop support
   - Timer accuracy
   - Offline functionality
   - Responsive UI
   - Data persistence
   - State restoration on app restart

## Future Enhancements (Potential)
- Support for different team sizes (5v5, 11v11)
- Support for different formations
- Player statistics over multiple games
- Export game data
- Team communication features
- Special handling for goalkeeper position
- Play time balance warnings
- Substitution suggestions based on play time

## Field Layout
```
       [GK]
    [D]    [D]
[M]    [M]    [M]
       [F]
```
Position Key:
- GK: Goalkeeper
- D: Defender
- M: Midfielder
- F: Forward 