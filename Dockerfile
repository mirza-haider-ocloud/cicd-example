
FROM --platform=linux/amd64 python:3.9


WORKDIR /code


COPY ./requirements.txt /code/requirements.txt


RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt


COPY . /code/


CMD ["fastapi", "run", "app/main.py", "--port", "80"]
