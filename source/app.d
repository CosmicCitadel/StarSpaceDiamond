import std.stdio;
import Dgame.Window.Window;
import Dgame.System.Font;

import GameState;

void main() {
	Window win = Window(800, 600, "StarSpaceDiamond");
	win.setVerticalSync(Window.VerticalSync.Enable);
	//TitleState title = new TitleState(win);
	Font font = Font("resources/font.ttf", 16);
	GameState[int] state;
	state[Tracker.TITLE] = new TitleState(win);
	state[Tracker.PLAYING] = new PlayingState(win, font);
	state[Tracker.LEVEL2] = new PlayingLevel2(win, font);
	Tracker.currentState = Tracker.TITLE;

	while(Tracker.running) {
		Tracker.dt = Tracker.sw.getElapsedTicks();
		Tracker.sw.reset();
		debug {
			Tracker.sw.wait(1000 / 60);
		}
		state[Tracker.currentState].render();
	}
}
