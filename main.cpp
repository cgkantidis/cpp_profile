#include <chrono>
#include <functional>
#include <iostream>
#include <numeric>
#include <vector>
#include <thread>

double add_doubles(double a, double b) {
  return a + b;
}

double sum1(std::vector<double> const &vec) {
  return std::accumulate(vec.begin(), vec.end(), 0.0);
}

double sum2(std::vector<double> const &vec) {
  return std::accumulate(vec.begin(), vec.end(), 0.0, add_doubles);
}

double sum3(std::vector<double> const &vec) {
  return std::reduce(vec.begin(), vec.end(), 0.0, add_doubles);
}

void bench(
    char const *name,
    double (*func)(std::vector<double> const &),
    std::vector<double> const &values) {
  const auto t1 = std::chrono::high_resolution_clock::now();
  auto const sum = func(values);
  const auto t2 = std::chrono::high_resolution_clock::now();
  const std::chrono::duration<double, std::milli> ms = t2 - t1;
  std::cout << name << ": " << sum << '\t' << "time: " << ms.count() << " ms\n";
}

int main() {
  const std::vector<double> values(100'000'007, 0.1);
  // single-threaded
  bench("sum1", sum1, values);
  bench("sum2", sum2, values);
  bench("sum3", sum3, values);

  // multi-threaded
  std::jthread t1(bench, "sum1", std::ref(sum1), std::ref(values));
  std::jthread t2(bench, "sum2", std::ref(sum2), std::ref(values));
  std::jthread t3(bench, "sum3", std::ref(sum3), std::ref(values));
}
