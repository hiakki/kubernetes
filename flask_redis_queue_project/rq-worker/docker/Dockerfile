FROM python:3.6.10

COPY . /flask_plutus
WORKDIR /flask_plutus
RUN pip install setuptools==45
RUN pip install -r /flask_plutus/requirements.txt
CMD ["rq", "worker", "--config", "settings"]
