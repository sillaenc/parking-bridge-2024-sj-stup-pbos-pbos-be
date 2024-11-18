실행 방법
1. VSCode에서 폴더 기준으로 Open
2. Dart pub get
3. 우측 상단 실행 버튼 클릭

개발 정보
1. db는 prototype 기준 sqllite를 사용한다.
2. RasberryPi4에 백엔드를 돌린다만, needs로 인해 트래픽 처리등 기초적인 부하에 대한 신경은 일절 쓰지 않는다. 이에 따른 책임은 본 개발자에 없다.
3. dart backend에 ws4sqllite를 사용해 sqllite의 보안성을 보완하는 목표를 가지는데 의의를 둔다.
4. 변수명은 일반적으로 lowerCamelCase로 진행했다. 클래스는 UpperCamelCase로 진행했다. sql문은 lowerCamelCase로 진행했다.
5. 인메모리 DB를 활용하였음. 인메모리 DB 사용으로 인한 부작용은 제작자 입장으로는 현재는 문제 없으나, RaspberryPi로 전환시 파악이 힘들다는 단점이 존재함.
6. PORT 정보는 env에 존재한다.