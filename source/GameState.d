module GameState;

import std.stdio;
import std.math;
import std.algorithm.mutation;
import std.string;

import Dgame.Window.Window;
import Dgame.Window.Event;
import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;
import Dgame.Graphic.Text;
import Dgame.Graphic.Color;
import Dgame.Math.Rect;
import Dgame.Math.Vector2;
import Dgame.System.Font;
import Dgame.System.Keyboard;
import Dgame.System.StopWatch;

import GameObject;

struct Tracker {
  static enum {TITLE, PLAYING, LEVEL2, LEVEL3};
  static int currentState = TITLE;
  static bool running = true;
  static StopWatch sw;
  static uint dt;
  static int score = 0;
  static GameState[int] state;
  static Font font;
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
  Puff[int] puff;
  StarDiamond[int] diamonds;
  int diamondCount = 0;
  Vector2f diamondPosition;
  Text text;
  static int thingNumber = 1;

  this(ref Window win, int thingNumber) {
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
    PlayingState.thingNumber += thingNumber;
    foreach (i; 0..PlayingState.thingNumber) {
      faces[i] = new SpaceThing(faceLocation);
    }
    text = new Text(Tracker.font, format("Score: %d", Tracker.score));
    text.foreground = Color4b.White;
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
      foreach (i, ref f; faces) {
        f.move();
        win.draw(f.sprite);
        Rect rect = f.sprite.getClipRect();
        foreach (ref l; lazer) {
          Rect lr = l.sprite.getClipRect();
          if (rect.intersects(lr)) {
            debug {
              writeln("Ding");
            }
            Tracker.score += f.value;
            //text.setData(format("Score: %d", Tracker.score));
            diamondCount += 2;
            diamondPosition = f.sprite.getPosition();
            puff[i] = new Puff("resources/puff.png");
            puff[i].sprite.setPosition(f.sprite.getPosition());
            faces.remove(i);
            Lazer.onscreen = false;
          }
        }
        //win.draw(f.sprite);
      }
      while(diamondCount > 0) {
        StarDiamond d = new StarDiamond("resources/stardiamond.png");
        d.sprite.setPosition(diamondPosition);
        diamonds[d.id] = d;
        --diamondCount;
      }
      foreach (i, ref d; diamonds) {
        if (d.onscreen) {
          d.move();
          win.draw(d.sprite);
          Rect drect = d.sprite.getClipRect();
          foreach(i, ref f; faces) {
            if (drect.intersects(f.sprite.getClipRect())) {
              debug {
                writeln("Another ding");
              }
              Tracker.score += f.value + 5;
              //text.setData(format("Score: %d", Tracker.score));
              diamondCount += 2;
              diamondPosition = f.sprite.getPosition();
              puff[i] = new Puff("resources/puff.png");
              puff[i].sprite.setPosition(diamondPosition);
              faces.remove(i);
              d.onscreen = false;
            }
          }
          if (drect.intersects(ship.sprite.getClipRect())) {
            debug {
              writeln("Sparkle!");
            }
            Tracker.score += d.value;
            //text.setData(format("Score: %d", Tracker.score));
            d.onscreen = false;
          }
        }
        else {
          diamonds.remove(i);
          //diamonds = diamonds.remove(i);
        }
      }
      foreach (i, ref l; lazer) {
        if (Lazer.onscreen) {
          l.move();
          win.draw(l.sprite);
        }
        else {
          lazer.remove(i);
        }
      }
      foreach (i, ref p; puff) {
        p.check();
        if (p.onscreen) {
          win.draw(p.sprite);
        }
        else {
          p.onscreen = false;
          puff.remove(i);
        }
      }
      ship.move();

      //win.draw(stars1);
      //win.draw(face.sprite);
      if (faces.length == 0 && diamonds.length == 0) {
        //Tracker.currentState = Tracker.LEVEL2;
        /*if (Tracker.currentState < Tracker.LEVEL3) {
          ++Tracker.currentState;
        }*/
        Tracker.state[Tracker.PLAYING] = new PlayingState(*win, 2);
      }
      win.draw(ship.sprite);
      text.setData(format("Score: %d", Tracker.score));
      win.draw(text);
      win.display();
  }
}

class PlayingLevel2 : PlayingState {

  this(ref Window win, int thingNumber) {
    super(win, thingNumber);
  }
}
