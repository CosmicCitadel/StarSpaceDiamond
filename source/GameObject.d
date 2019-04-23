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
  int destinationx;
  int destinationy;

  this(string file) {
    super(file);
    destinationx = uniform(0, 800);
    destinationy = uniform(0, 600);
  }

  override void move() {
    if (sprite.x < destinationx) {
      sprite.x = sprite.x + speed;
    }
    else if (sprite.x > destinationx) {
      sprite.x = sprite.x - speed;
    }
    if (sprite.y < destinationy) {
      sprite.y = sprite.y + speed;
    }
    else if (sprite.y > destinationy) {
      sprite.y = sprite.y - speed;
    }

    if (sprite.x < destinationx - 10 || sprite.x > destinationx + 10) {
      if (sprite.y < destinationy - 10 || sprite.y > destinationy + 10) {
        destinationx = uniform(0, 800);
        destinationy = uniform(0, 600);
      }
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
