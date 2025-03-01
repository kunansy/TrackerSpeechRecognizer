FROM python:3.12-slim-bullseye

LABEL maintainer="<k@kunansy.ru>"
ENV PYTHONUNBUFFERED=1
ENV PYTHONOPTIMIZE=2

COPY --from=kunansy/ffmpeg:5.1.1 /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=kunansy/ffmpeg:5.1.1 /usr/local/bin/ffprobe /usr/local/bin/ffprobe

COPY poetry.lock pyproject.toml entrypoint.sh /

RUN apt-get update \
    && apt-get -y install curl gcc portaudio19-dev flac libasound-dev \
    && pip install -U pip poetry==2.0.0 --no-cache-dir \
    && poetry config virtualenvs.create false \
    && poetry install --only main -n --no-root \
    && ./entrypoint.sh \
    && rm poetry.lock pyproject.toml entrypoint.sh  \
    && pip uninstall -y poetry \
    && apt-get remove gcc -y \
    && apt-get autoremove -y \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

USER tracker
WORKDIR /app

COPY /speech_recognizer ./speech_recognizer
COPY VERSION ./VERSION
