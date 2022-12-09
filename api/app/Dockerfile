FROM python:3.11

WORKDIR /usr/src/app

COPY requirements.txt .

RUN python3 -m ensurepip
RUN pip install --no-cache --upgrade pip setuptools
RUN pip install -r requirements.txt

ENV PYTHONPATH "${PYTHONPATH}:/usr/src/app/src"