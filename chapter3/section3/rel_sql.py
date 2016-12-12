# coding=utf-8
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship

from consts import DB_URI

eng = create_engine(DB_URI)
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50))

class Address(Base):
    __tablename__ = 'address'

    id = Column(Integer, primary_key=True, autoinctrement=True)
    email_address = Column(String(128), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'))
    user = relationship('User', back_populaters='addresses')

User.addresses = relationship('Address', order_by=Address.id,
                              back_populates='user')


    
