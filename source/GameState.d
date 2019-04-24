module GameState;

import std.stdio;
import std.math;

import Dgame.Window.Window;
import Dgame.Window.Event;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;
import Dgame.Math.Rect;
import Dgame.System.Keyboard;
import Dgame.System.StopWatch;

import GameObject;

struct Tracker {
  static enum {TITLE, PLAYING};
  static int currentState = TITLE;
  static bool running = true;
  static StopWatch sw;
  static uint dt;
}

class GameState {
  Window* win;
  Event evt;

  this(ref Window win) {
    this.win = &win;
  }

  void render() {}
}

class TitleState : GameState {

  Texture tex;
  Sprite title;

  this(ref Window win) {
    super(win);
    tex = Texture(Surface("resources/title.png"));
    title = new Sprite(tex);
  }

  override void render() {
      while(win.poll(&evt)) {
        switch(evt.type) {
          case Event.Type.KeyDown:
            if (evt.keyboard.key == Keyboard.Key.Return) {
              Tracker.currentState = Tracker.PLAYING;
            }
          break;
          case Event.Type.Quit:
            Tracker.running = false;
          break;
          default: break;
        }
      }

      win.draw(title);
      win.display();
  }
}

class PlayingState : GameState {

  Texture stars1T;
  Sprite stars1;
  Ship ship;
  SpaceThing face;
  string faceLocation = "resources/facething.png";
  SpaceThing[int] faces;
  Lazer[int] lazer;

  this(ref Window win) {
    super(win);
    stars1T = Texture(Surface("resources/stars1.png"));
    stars1 = new Sprite(stars1T);
    ship = new Ship("resources/ship.png");
    ship.speed = 0;
    ship.turnSpeed = 0.2;
    //ship.acceleration = 0.0006;
    ship.acceleration = 0.003;
    ship.maxSpeed = 2.0;
    //ship.sprite.setRotationCenter(ship.tex.width() / 2, ship.tex.height() / 2);
    ship.sprite.setOrigin(30, 30);
    ship.sprite.setPosition(win.getSize().width / 2, win.getSize().height / 1.25);
    ship.sprite.rotate(-90);
    foreach (i; 0..3) {
      faces[i] = new SpaceThing(faceLocation);
    }
  }

  override void render() {
      while(win.poll(&evt)) {
        switch(evt.type) {
          case Event.Type.KeyDown:
            if (evt.keyboard.key == Keyboard.Key.Left) {
              ship.turnLeft = true;
            }
            else if (evt.keyboard.key == Keyboard.Key.Right) {
              ship.turnRight = true;
            }
            if (evt.keyboard.key == Keyboard.Key.Up) {
              ship.shipUp = true;
              ship.speed = ship.acceleration;
            }
            if (evt.keyboard.key == Keyboard.Key.LCtrl) {
              if (!Lazer.onscreen) {
                lazer[0] = new Lazer("resources/shiplazer.png", ship.sprite.getRotation());
                lazer[0].sprite.setPosition(ship.sprite.getPosition());
                Lazer.onscreen = true;
              }
            }
            if (evt.keyboard.key == Keyboard.Key.R) {
              ship.reset();
            }
          break;
          case Event.Type.KeyUp:
            if (evt.keyboard.key == Keyboard.Key.Left) {
              ship.turnLeft = false;
            }
            else if (evt.keyboard.key == Keyboard.Key.Right) {
              ship.turnRight = false;
            }
            if (evt.keyboard.key == Keyboard.Key.Up) {
              ship.shipUp = false;
              ship.speed = 0;
            }
          break;
          case Event.Type.Quit:
            Tracker.running = false;
          break;
          default: break;
        }
      }

      if (ship.turnLeft) {
        ship.sprite.rotate(-ship.turnSpeed * Tracker.dt);
      }
      else if (ship.turnRight) {
        ship.sprite.rotate(ship.turnSpeed * Tracker.dt);
      }

      win.draw(stars1);
      foreach (ref f; faces) {
        f.move();
        Rect rect = f.sprite.getClipRect();
        foreach (ref l; lazer) {
          Rect lr = l.sprite.getClipRect();
          if (rect.intersects(lr)) {
            debug {
              writeln("Ding");
            }
          }
        }
        win.draw(f.sprite);
      }
      foreach (ref l; lazer) {
        if (Lazer.onscreen) {
          l.move();
          win.draw(l.sprite);
        }
      }
      ship.move();

      //win.draw(stars1);
      //win.draw(face.sprite);
      win.draw(ship.sprite);
      win.display();
  }
}
