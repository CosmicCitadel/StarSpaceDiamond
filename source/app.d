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
		state[Tracker.currentState].render();
	}
}
