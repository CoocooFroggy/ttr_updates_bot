FROM dart:stable

WORKDIR /bot

# Install panda3d
ADD docker_panda.sh .
RUN ./docker_panda.sh

# Install dependencies
COPY pubspec.* /bot/
RUN dart pub get

# Copy code
COPY . /bot/
RUN dart pub get --offline

# Compile bot into executable
RUN dart run nyxx_commands:compile --compile -o ttr_updates_bot.g.dart --no-compile bin/ttr_updates_bot.dart
RUN dart compile exe -o ttr_updates_bot ttr_updates_bot.g.dart

CMD [ "./ttr_updates_bot" ]
