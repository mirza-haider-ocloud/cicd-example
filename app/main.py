from typing import Union
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session

from app.database import Base, SessionLocal, engine
from . import schemas, models


app = FastAPI()

# Create db models (But use Alembic in production)
Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"Hello": "Bingo"}



@app.post("/users", response_model=Union[schemas.UserResponse, str])
def create_user(
    user: schemas.UserCreate,
    db: Session = Depends(get_db)
):
    duplicate = db.query(models.User).filter(models.User.email == user.email).first()
    if duplicate:
        return "User already exists!"
    
    db_user = models.User(**user.model_dump())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@app.get("/users/{user_id}", response_model=Union[schemas.UserResponse, str])
def get_user(
    user_id: int,
    db: Session = Depends(get_db)
):
    user = db.get(models.User, user_id)
    if not user:
        return "User not found!"
    else:
        return user


@app.get("/users", response_model=list[schemas.UserResponse])
def get_all_users(
    db: Session = Depends(get_db)
):
    users = db.query(models.User).all()
    return users
