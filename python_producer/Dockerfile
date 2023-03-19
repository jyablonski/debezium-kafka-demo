FROM python:3.9-slim as base

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1


FROM base AS python-deps

COPY python_producer/install_packages.sh .
RUN ./install_packages.sh

COPY python_producer/Pipfile .
COPY python_producer/Pipfile.lock .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy
# this makes it so the build will fail if i dont pipenv lock beforehand


FROM base AS runtime

COPY --from=python-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

RUN useradd --create-home appuser
WORKDIR /home/appuser

COPY python_producer/app.py ./app.py
COPY python_producer/example.log ./example.log
ENV PYTHONUNBUFFERED=1

USER appuser

CMD ["python3", "app.py"]