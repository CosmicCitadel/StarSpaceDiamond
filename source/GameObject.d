module GameObject;

import std.stdio;
import std.math;
import std.random;

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

    if (sprite.x - 30 > 800) sprite.x = -30;
    else if (sprite.x + 30 < 0) sprite.x = 830;
    if (sprite.y - 30 > 600) sprite.y = -30;
    else if (sprite.y + 30 < 0) sprite.y = 630;

    sprite.move(velx, vely);
  }

  void reset() {
    sprite.setPosition(300, 300);
  }
}

class SpaceThing : GameObject {

  uint direction = 0;
  //float speed = 3.0;
  float speed = 0.2;
  int px;
  int py;

  this(string file) {
    super(file);
    px = uniform(0, 800);
    py = uniform(0, 600);
    sprite.x = uniform(0, 800);
    sprite.y = uniform(0, 600);
  }

  override void move() {
    if (sprite.x < px) {
      sprite.x = sprite.x + speed * Tracker.dt;
    }
    else if (sprite.x > px) {
      sprite.x = sprite.x - speed * Tracker.dt;
    }
    if (sprite.y < py) {
      sprite.y = sprite.y + speed * Tracker.dt;
    }
    else if (sprite.y > py) {
      sprite.y = sprite.y - speed * Tracker.dt;
    }

    if (sprite.x <= px && sprite.x > px - 2 || sprite.x >= px && sprite.x < px + 2) {
      px = uniform(0, 800);
    }

    if (sprite.y <= py && sprite.y > py - 2 || sprite.y >= py && sprite.y < py + 2) {
      py = uniform(0, 600);
    }

  }
}

class StarDiamond : GameObject {

  float speed = 3.0;
  float dx;
  float dy;

  this(string file, float dx, float dy) {
    super(file);
    this.dx = dx;
    this.dy = dy;
  }

  override void move() {
    sprite.move(dx, dy);
  }
}

class Lazer : GameObject {

  float speed = 0.3;
  float deg;
  float dx;
  float dy;

  this(string file, float rotation) {
    super(file);
    sprite.rotate(rotation - 90);
    deg = rotation * PI / 180.0;
    dx = cos(deg);
    dy = sin(deg);
  }

  override void move() {
    sprite.move(dx * speed * Tracker.dt, dy * speed * Tracker.dt);
  }
}
