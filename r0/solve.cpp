#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <set>
#include <string>
#include <vector>

std::vector<int> //
intlist(std::string const &src) {
  std::vector<int> r;
  auto p = src.c_str();
  for (;;) {
    char *end = nullptr;
    auto n = std::strtol(p, &end, 10);
    r.push_back(n);
    if (!end || 0 == *end) {
      return r;
    }
    p = end + 1;
  }
}

template <typename T, typename U> //
std::string join(T const &c, U const &s) {
  std::string r;
  for (auto const &v : c) {
    if (!r.empty()) {
      r += s;
    }
    r += std::to_string(v);
  }
  return r;
}

struct pos_t {
  int x_, y_;
  std::pair<int, int> //
  comp_by() const {
    return std::make_pair(x_ + y_, x_);
  }

  pos_t(int x, int y) : x_(x), y_(y) {}
};

bool operator<(pos_t const &a, pos_t const &b) { //
  return a.comp_by() < b.comp_by();
}

struct range_t {
  int left_, w_;
  int left() const { return left_; }
  int right() const { return left_ + w_; }
  bool intersect(range_t const &o) const {
    auto l = std::max(left(), o.left());
    auto r = std::min(right(), o.right());
    return l < r;
  }
  bool touching(range_t const &o) const {
    return left() == o.right() || right() == o.left();
  }
};

struct rect_t {
  pos_t pos_;
  int w_;
  rect_t(pos_t const &pos, int w) : pos_(pos), w_(w) {}
  int right() const { return pos_.x_ + w_; }
  int top() const { return pos_.y_ + w_; }
  range_t xrange() const { return {pos_.x_, w_}; }
  range_t yrange() const { return {pos_.y_, w_}; }
  bool intersect(rect_t const &o) const {
    return xrange().intersect(o.xrange()) //
           && yrange().intersect(o.yrange());
  }
  bool is_neibour(rect_t const &o) const {
    return (xrange().intersect(o.xrange()) && yrange().touching(o.yrange())) //
           || (yrange().intersect(o.yrange()) && xrange().touching(o.xrange()));
  }
};

struct field_t {
  std::vector<rect_t> rects_;
  std::set<pos_t> cands_{pos_t{0, 0}};
  std::set<int> x_{0};
  std::set<int> y_{0};
  size_t max_ix_ = 0;
  int max_size_ = -1;
  //
  void updateMax(int size) {
    if (max_size_ < size) {
      max_size_ = size;
      max_ix_ = rects_.size();
    }
  }
  bool can_place(rect_t const &c) const {
    for (auto const &r : rects_) {
      if (r.intersect(c)) {
        return false;
      }
    }
    return true;
  }
  rect_t find_pos(int size) const {
    for (auto const &p : cands_) {
      rect_t c{p, size};
      if (can_place(c)) {
        return c;
      }
    }
    throw std::runtime_error("logic error");
  }
  void add_pos(int x, int y) {
    bool add_x = cend(x_) == x_.find(x);
    bool add_y = cend(y_) == y_.find(y);
    x_.insert(x);
    y_.insert(y);
    if (add_x) {
      for (auto i : y_) {
        cands_.emplace(x, i);
      }
    }
    if (add_y) {
      for (auto i : x_) {
        cands_.emplace(i, y);
      }
    }
  }
  void place(int size) {
    updateMax(size);
    rect_t r = find_pos(size);
    rects_.push_back(r);
    add_pos(r.right(), r.top());
  }
  std::multiset<int> neibours(size_t rect_ix) const {
    std::multiset<int> r;
    auto const &mr = rects_[rect_ix];
    for (size_t ix = 0; ix < rects_.size(); ++ix) {
      if (ix == rect_ix) {
        continue;
      }
      auto const &c = rects_[ix];
      if (c.is_neibour(mr)) {
        r.insert(c.w_);
      }
    }
    return r;
  }
};

std::string solve(std::string const &src) {
  field_t f;
  for (auto size : intlist(src)) {
    f.place(size);
  }
  auto s = f.neibours(f.max_ix_);
  return join(s, ",");
}

void test(std::string const &src, std::string const &expected) {
  std::string actual = solve(src);
  char const *res = actual == expected ? "ok" : "***NG***";
  printf(R"(%s %s->"%s", wants "%s")"
         "\n",
         res, src.c_str(), actual.c_str(), expected.c_str());
}

int main() {
  // clang-format off
  /*0*/ test( "27,17,8,36,16,12,11,13,25,23,10,6,2,9", "2,8,9,10,13,23,27" );
  /*1*/ test( "1,2,3", "2" );
  /*2*/ test( "4,3,5,2,1", "1,4" );
  /*3*/ test( "3,2,1,4,3,2,1", "1,1,2,3" );
  /*4*/ test( "9,8,7,12,11,10,2,5", "5,7,9,10,11" );
  /*5*/ test( "6,2,2,4,4,2,2,7,4,4,1,5", "2,4,4,4,6" );
  /*6*/ test( "5,25,6,24,7,23,8,22,9,21", "5,6,7,8,24" );
  /*7*/ test( "6,6,6,14,3,3,1,2,15,7,8,9", "3,8,9" );
  /*8*/ test( "6,7,8,9,6,7,8,9,10,6,7,8,9", "7,9,9" );
  /*9*/ test( "1,1,2,3,5,8,13,21,34,55,89,144", "55,89" );
  /*10*/ test( "144,89,55,34,21,13,8,5,3,2,1,1", "34,55,89" );
  /*11*/ test( "5,3,4,2,25,6,24,7,23,8,22,9,2,1", "1,3,5,6,7,8,24" );
  /*12*/ test( "2,9,9,9,3,8,8,8,10,7,7,7,6,6,5,5", "6,8,9" );
  /*13*/ test( "1,2,3,4,5,6,7,8,9,8,7,6,5,4,3,2,1", "5,6,7,8,8" );
  /*14*/ test( "1,6,6,6,2,6,6,6,3,6,6,6,7,6,6,6,4,5", "3,5,6,6,6" );
  /*15*/ test( "4,4,4,5,5,5,6,6,6,6,7,7,5,9,5,4,4,8", "5,5,6,6,8" );
  /*16*/ test( "5,4,3,40,9,8,7,6,5,4,3,2,1,5,4,3,2,1", "1,1,3,3,3,5,5,5,6,8,9" );
  /*17*/ test( "83,26,119,18,32,57,41,98,113,120,28,20", "41,98,119" );
  /*18*/ test( "10,12,25,14,11,16,10,17,5,5,15,19,13,18", "5,10,11,12,14,17" );
  /*19*/ test( "1,3,5,7,9,11,13,15,17,16,14,12,10,8,6,4,2", "10,12,13,15,16" );
  /*20*/ test( "12,87,40,44,43,59,83,35,97,29,17,39,84,24", "24,43,87" );
  /*21*/ test( "20,21,22,23,24,25,26,27,28,29,6,3,3,3,3,3", "3,6,27,28" );
  /*22*/ test( "5,15,6,16,7,17,8,18,9,19,10,20,9,10,11,12", "10,12,19" );
  /*23*/ test( "5,5,5,4,9,4,5,5,3,7,6,6,8,2,3,2,8,2,2,6,5", "2,3,5,5,6,7" );
  /*24*/ test( "94,93,104,120,36,88,67,37,83,92,25,103,75,22", "22,92,93,103" );
  /*25*/ test( "16,15,14,13,12,11,10,29,28,27,26,25,24,4,10,9", "4,9,11,15,26,27" );
  /*26*/ test( "84,87,21,18,83,119,17,28,37,88,13,91,49,76,24", "76,83,87,88" );
  /*27*/ test( "41,16,26,94,68,74,21,116,50,31,47,86,39,94,106", "39,68,94,106" );
  /*28*/ test( "70,40,67,49,105,59,117,42,89,83,73,15,96,57,17", "73,96,105" );
  /*29*/ test( "8,9,10,11,12,13,14,15,16,17,18,6,5,4,3,7,6,5,4", "4,6,15,16" );
  /*30*/ test( "9,8,7,20,6,6,5,5,4,4,3,3,2,2,1,1,10,11,12,6,5,4", "1,1,2,3,3,5,6,7,9,12" );
  /*31*/ test( "15,15,15,5,14,6,7,8,9,10,11,12,13,14,15,16,17,18", "16,17" );
  /*32*/ test( "70,80,81,42,77,30,53,43,120,77,108,53,16,44,43,28", "43,43,53,77,108" );
  /*33*/ test( "88,107,125,102,130,24,38,29,105,63,58,53,109,98,94", "63,94,98,107,125" );
  /*34*/ test( "96,119,112,20,16,46,30,76,112,57,105,56,107,51,53,26", "26,30,46,57,96,112" );
  /*35*/ test( "110,112,117,56,60,120,16,86,47,96,85,84,75,60,72,68,38", "68,75,84,117" );
  /*36*/ test( "98,52,17,78,34,120,109,62,46,31,22,43,64,110,105,51,1,2,3", "22,43,52,62,98,105" );
  /*37*/ test( "2,5,11,17,23,31,41,47,59,67,73,71,61,53,43,37,29,19,13,7,3", "43,53,59,67,71" );
  /*38*/ test( "13,62,74,40,51,16,27,81,43,15,120,15,56,16,101,20,35,102,73,21", "21,51,73,102" );
  /*39*/ test( "64,94,98,119,25,36,115,14,44,13,40,92,50,46,62,53,66,118,32,27", "27,40,46,92,94,118" );
  /*40*/ test( "95,86,41,115,73,41,24,87,101,72,102,77,81,47,66,66,99,18,39,13", "18,41,41,87,95,101,102" );
  /*41*/ test( "22,118,89,80,45,120,85,37,69,96,20,13,118,45,74,92,38,91,87,111", "38,45,74,89,91" );
  /*42*/ test( "82,46,118,13,85,103,80,28,86,89,54,92,15,94,69,93,66,60,22,14,15", "15,22,80,82,89,103" );
  /*43*/ test( "42,37,24,18,19,33,16,6,11,27,17,25,7,9,35,48,49,50,15,8,4,2,30,29", "15,25,29,35" );
  /*44*/ test( "43,36,58,54,84,116,68,95,61,22,16,14,68,25,109,37,66,74,31,43,75,49", "31,54,61,66,75,95" );
  /*45*/ test( "126,22,76,25,32,45,37,148,47,56,17,146,56,72,78,54,32,141,21,46,140,83", "32,54,76,78,83,126" );
  /*46*/ test( "85,100,122,117,107,68,63,22,130,63,57,49,71,70,117,82,14,51,59,68,69,116", "68,68,116,122" );
  /*47*/ test( "69,52,123,101,65,27,22,103,99,133,152,25,93,34,55,36,81,29,112,28,83,46,127,27,43", "46,103,133" );
  /*48*/ test( "97,39,129,49,86,94,153,85,28,96,96,140,82,107,140,106,91,106,124,147,95,144,89,60,52", "82,106,129,140" );
  /*49*/ test( "127,52,46,85,104,147,148,93,76,55,143,106,38,22,66,143,85,113,145,81,138,38,23,29,19,20,16,10", "10,16,20,29,104,106,143,145,147" );
  /*50*/ test( "132,88,143,97,156,149,133,119,138,89,148,18,104,115,37,50,90,91,125,145,111,134,64,149,124,28", "18,28,89,97,104,119,143" );
  /*51*/ test( "156,41,97,44,167,114,98,83,130,51,55,78,134,39,95,104,147,43,98,126,36,156,66,129,24,97,21,8,7", "8,21,44,55,83,98,134,156" );
  /*52*/ test( "48,47,146,39,56,49,19,128,151,27,24,150,73,167,80,58,34,85,148,23,160,138,34,74,61,120,58,158,117", "58,61,117,128,151,160" );
  /*53*/ test( "134,162,87,47,160,93,199,125,117,69,45,198,40,35,197,51,55,96,147,145,90,73,72,71,70,146,26,33,7,24", "26,33,51,55,69,145,147,160,162" );
  /*54*/ test( "73,147,153,172,171,70,97,20,124,64,44,17,60,45,131,26,43,173,111,172,25,84,147,52,68,19,40,48,38,37", "26,37,38,48,172" );
  // clang-format on
}
