import std.stdio;
import Dgame.Window.Window;

import GameState;

void main() {
	Window win = Window(800, 600, "StarSpaceDiamond");
	win.setVerticalSync(Window.VerticalSync.Enable);
	//TitleState title = new TitleState(win);
	GameState[int] state;
	state[Tracker.TITLE] = new TitleState(win);
	state[Tracker.PLAYING] = new PlayingState(win);
	Tracker.currentState = Tracker.TITLE;

	while(Tracker.running) {
		Tracker.dt = Tracker.sw.getElapsedTicks();
		Tracker.sw.reset();
		debug {
			Tracker.sw.wait(1000 / 60);
			writeln("Debugging");
		}
		state[Tracker.currentState].render();
	}
}
