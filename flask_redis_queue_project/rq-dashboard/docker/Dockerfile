FROM python:3.6.10-alpine3.11

COPY . /flask_plutus
WORKDIR /flask_plutus
RUN pip install -r /flask_plutus/requirements.txt
EXPOSE 9181
CMD ["rq-dashboard", "--port", "9181", \
                     "--redis-host", "redis-master", \
                     "--redis-port", "6379"]
