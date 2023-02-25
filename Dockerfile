FROM dart:stable

WORKDIR /bot

# TODO: Install panda3d
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
