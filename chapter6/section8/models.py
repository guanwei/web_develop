# coding=utf-8
import os
import uuid
import magic
import urllib
from datetime import datetime

import cropresize2
import short_url
from PIL import Image
from flask import abort, request
from werkzeug.utils import cached_property
from mongoengine import (
    Document as BaseDocument, connect, ValidationError, DoesNotExist,
    QuerySet, MultipleObjectsReturned, IntField, DateTimeField, StringField,
    SequenceField)

from mimes import IMAGE_MIMES, AUDIO_MIMES, VIDEO_MIMES
from utils import get_file_md5, get_file_path

connect('r', host='localhost', port=27017)


class BaseQuerySet(QuerySet):
    def get_or_404(self, *args, **kwargs):
        try:
            return self.get(*args, **kwargs)
        except (MultipleObjectsReturned, DoesNotExist, ValidationError):
            abort(404)


class Document(BaseDocument):
    meta = {'abstract': True,
            'queryset_class': BaseQuerySet}


class PasteFile(Document):
    id = SequenceField(primary_key=True)
    filename = StringField(max_length=5000, null=False)
    filehash = StringField(max_length=128, null=False, unique=True)
    filemd5 = StringField(max_length=128, null=False, unique=True)
    uploadtime = DateTimeField(null=False)
    mimetype = StringField(max_length=128, null=False)
    size = IntField(null=False)
    meta = {'collection': 'paste_file'}  # 自定义集合的名字

    def __init__(self, filename='', mimetype='application/octet-stream',
                 size=0, filehash=None, filemd5=None, *args, **kwargs):
        # 初始化父类的__init__方法
        super(PasteFile, self).__init__(filename=filename, mimetype=mimetype,
                                        size=size, filehash=filehash,
                                        filemd5=filemd5, *args, **kwargs)
        self.uploadtime = datetime.now()
        self.mimetype = mimetype
        self.size = int(size)
        self.filehash = filehash if filehash else self._hash_filename(filename)
        self.filename = filename if filename else self.filehash
        self.filemd5 = filemd5

    @staticmethod
    def _hash_filename(filename):
        _, _, suffix = filename.rpartition('.')
        return '%s.%s' % (uuid.uuid4().hex, suffix)

    @cached_property
    def symlink(self):
        return short_url.encode_url(self.id)

    @classmethod
    def get_by_symlink(cls, symlink, code=404):
        id = short_url.decode_url(symlink)
        return cls.objects.get_or_404(id=id)

    @classmethod
    def get_by_filehash(cls, filehash, code=404):
        return cls.objects.get_or_404(filehash=filehash)

    @classmethod
    def get_by_md5(cls, filemd5):
        rs = cls.objects(filemd5=filemd5)
        return rs[0] if rs else None

    @classmethod
    def

