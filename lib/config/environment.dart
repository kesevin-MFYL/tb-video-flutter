enum Environment {
  development('http://xxx.xxx.xxx'),
  test('http://xxx.xxx.xxx'),
  production('http://xxx.xxx.xxx');

  final String domain;
  const Environment(this.domain);
}
