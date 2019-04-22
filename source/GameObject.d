module GameObject;

import std.stdio;
import std.math;

import Dgame.Graphic.Surface;
import Dgame.Graphic.Texture;
import Dgame.Graphic.Sprite;

import GameState : Tracker;

class GameObject {
  Texture tex;
  Sprite sprite;

  uint width;
  uint height;

  this(string file) {
    tex = Texture(Surface(file));
    tex.setSmooth(true);
    width = tex.width();
    height = tex.height();
    sprite = new Sprite(tex);
  }

  void move() {}
}

class Ship : GameObject {

  float speed;
  float turnSpeed;
  float acceleration;
  float maxSpeed;
  float velx = 0;
  float vely = 0;

  bool turnLeft = false;
  bool turnRight = false;
  bool shipUp = false;

  this(string file) {
    super(file);
  }

  override void move() {
    float deg = sprite.getRotation() * PI / 180.0;
    float dx = cos(deg);
    float dy = sin(deg);
    velx += dx * speed * Tracker.dt;
    vely += dy * speed * Tracker.dt;

    if (velx > maxSpeed) velx = maxSpeed;
    else if (velx < -maxSpeed) velx = -maxSpeed;
    if (vely > maxSpeed) vely = maxSpeed;
    else if (vely < -maxSpeed) vely = -maxSpeed;

    if (sprite.x > 800) sprite.x = -60;
    else if (sprite.x + 60 < 0) sprite.x = 800;
    if (sprite.y > 600) sprite.y = -60;
    else if (sprite.y + 60 < 0) sprite.y = 600;

    sprite.move(velx, vely);
  }

  void reset() {
    sprite.setPosition(300, 300);
  }
}

class SpaceThing : GameObject {

  uint direction = 0;
  float speed = 2.0;

  this(string file) {
    super(file);
  }

  override void move() {
    if (direction == 1) {
      sprite.x = sprite.x + speed;
    }
    else {
      sprite.x = sprite.x - speed;
    }

    if (sprite.x < 0) {
      sprite.x = 0;
      direction = 1;
    }
    else if (sprite.x + width > 800) {
      sprite.x = 800 - width;
      direction = 0;
    }
  }
}
