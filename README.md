# SubSub - Soccer Substitution Manager

A mobile application designed to help coaches manage youth soccer teams during games, with a focus on fair play time distribution and easy substitution management. Built with Flutter and developed through AI-human collaboration.

## Features

### Team Management
- Maintain a persistent roster of players (stored locally)
  - Add new players with name and number
  - Remove players from roster
  - Edit player information
  - Data persists between app sessions using SQLite

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
- Haptic feedback for better user experience

### Game History
- Save completed game data locally
- View game history with detailed statistics
- Per game statistics:
  - Total play time per player
  - Total bench time per player
  - Number of substitutions
  - Game duration
  - Final formation snapshot

## Technical Stack

### Framework
- Flutter for cross-platform development
- Riverpod for state management
- SQLite for local data persistence
- Custom widgets for field visualization

### Architecture
- Clean separation of concerns:
  - Models: Data structures and business logic
  - Providers: State management
  - Screens: UI components
  - Services: Data persistence and business logic
  - Widgets: Reusable UI components

### Key Technical Features
- Drag and drop support with gesture handling
- Real-time timer updates
- Offline functionality
- Responsive UI
- Data persistence
- State restoration on app restart

## Development Journey

This project was developed through AI-human collaboration, demonstrating the potential of combining human expertise with AI capabilities. The development process included:

- ~150-200 prompts for feature implementation
- ~300-400 Claude requests for refinements
- 4,200 lines of code across 21 files
- Iterative development with real-world testing
- Focus on code quality and maintainability

For more details about the development process, see the [documentation](doc/).

## Getting Started

### Prerequisites
- Flutter SDK
- iOS device or simulator (for iOS development)
- Android device or emulator (for Android development)

### Installation
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Development Setup
See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed setup instructions.

## Future Enhancements
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