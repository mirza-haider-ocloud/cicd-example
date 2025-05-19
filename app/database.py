from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv
import os


load_dotenv()  # load variables from .env into os.environ


DATABASE_URL = os.getenv("DATABASE_URL")
DATABASE_URL = f"mysql+pymysql://myusername:mypassword@{DATABASE_URL}:3306/cicdExDB"


engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

Base = declarative_base()
