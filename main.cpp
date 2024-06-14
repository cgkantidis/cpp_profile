#include <chrono>
#include <iostream>
#include <numeric>
#include <vector>

double
add_doubles(double a, double b) {
  return a + b;
}

double
sum1(std::vector<double> const &vec) {
  return std::accumulate(vec.begin(), vec.end(), 0.0);
}

double
sum2(std::vector<double> const &vec) {
  return std::accumulate(vec.begin(), vec.end(), 0.0, add_doubles);
}

double
sum3(std::vector<double> const &vec) {
  return std::reduce(vec.begin(), vec.end(), 0.0, add_doubles);
}

int
main() {
  const std::vector<double> v(100'000'007, 0.1);

  {
    const auto t1 = std::chrono::high_resolution_clock::now();
    const auto val = sum1(v);
    const auto t2 = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> ms = t2 - t1;
    std::cout << "sum: " << val << '\t' << "time: " << ms.count() << " ms\n";
  }
  {
    const auto t1 = std::chrono::high_resolution_clock::now();
    const auto val = sum2(v);
    const auto t2 = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> ms = t2 - t1;
    std::cout << "sum: " << val << '\t' << "time: " << ms.count() << " ms\n";
  }
  {
    const auto t1 = std::chrono::high_resolution_clock::now();
    const auto val = sum3(v);
    const auto t2 = std::chrono::high_resolution_clock::now();
    const std::chrono::duration<double, std::milli> ms = t2 - t1;
    std::cout << "sum: " << val << '\t' << "time: " << ms.count() << " ms\n";
  }
}
