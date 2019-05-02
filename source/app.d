import std.stdio;
import Dgame.Window.Window;
import Dgame.System.Font;

import GameState;

void main() {
	Window win = Window(800, 600, "StarSpaceDiamond");
	win.setVerticalSync(Window.VerticalSync.Enable);
	//TitleState title = new TitleState(win);
	Font font = Font("resources/font.ttf", 16);
	//GameState[int] state;
	Tracker.state[Tracker.TITLE] = new TitleState(win);
	Tracker.state[Tracker.PLAYING] = new PlayingState(win, font, 3);
	//state[Tracker.LEVEL2] = new PlayingLevel2(win, font, 5);
	Tracker.state[Tracker.LEVEL2] = new PlayingState(win, font, 5);
	Tracker.state[Tracker.LEVEL3] = new PlayingState(win, font, 9);
	Tracker.currentState = Tracker.TITLE;

	while(Tracker.running) {
		Tracker.dt = Tracker.sw.getElapsedTicks();
		Tracker.sw.reset();
		debug {
			Tracker.sw.wait(1000 / 60);
		}
		Tracker.state[Tracker.currentState].render();
	}
}
