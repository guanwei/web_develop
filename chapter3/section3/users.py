# coding=utf-8
from ext import db

class User(db.Model):
    __tablename__ = 'user2'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(50))

    def __init__(self, name):
        self.name = name
