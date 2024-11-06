from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from config import *


# Create a database URL for SQLAlchemy
SQLALCHEMY_DATABASE_URL = f"postgresql://{pstgr_conf['user']}:{pstgr_conf['password']}@{pstgr_conf['host']}:{pstgr_conf['port']}/{pstgr_conf['database']}"
print(f"\n[!] DB {SQLALCHEMY_DATABASE_URL}")

# NB: IP find using:  docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres-0

# Create the SQLAlchemy engine:
engine = create_engine(
    SQLALCHEMY_DATABASE_URL    
)
# NB: The engine connect the script to Postgres database on port 5432.

# Create a SessionLocal class (database session)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create a Base class, Later we will inherit from this class to create each of the database models or classes (the ORM models)
Base = declarative_base()

