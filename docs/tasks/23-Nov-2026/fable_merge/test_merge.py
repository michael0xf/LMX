#!/usr/bin/env python3
"""Safety tests for the Fable helper; tests use disposable directories only."""
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import tarfile
import tempfile
import unittest

spec=importlib.util.spec_from_file_location('fable_merge',Path(__file__).with_name('merge.py'))
merge=importlib.util.module_from_spec(spec);spec.loader.exec_module(merge)


class MergeTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='fable-merge-test-')
        self.root=Path(self.temp.name);self.packet=self.root/'packet'/'fable_merge'
        self.packet.mkdir(parents=True);self.new=self.packet.parent/'spec';self.new.mkdir()
        self.target=self.root/'target';self.target.mkdir()

    def tearDown(self):self.temp.cleanup()

    def make(self,before,after,local=None,category='source'):
        local=before if local is None else local
        if after is not None:(self.new/'sample.txt').write_bytes(after)
        if local is not None:(self.target/'sample.txt').write_bytes(local)
        entries=[{'path':'sample.txt','before':merge.digest(before),'after':merge.digest(after),'category':category}]
        (self.packet/'changes.json').write_text(json.dumps({'format':1,'changes':entries}))
        with tarfile.open(self.packet/'base-files.tar.gz','w:gz') as t:
            if before is not None:
                m=tarfile.TarInfo('sample.txt');m.size=len(before);t.addfile(m,io.BytesIO(before))

    def test_matching_base_and_idempotence(self):
        self.make(b'old\n',b'new\n')
        _,rows,changes=merge.plan(self.packet,self.target)
        self.assertEqual(rows[0]['state'],'ready')
        self.assertEqual((self.target/'sample.txt').read_bytes(),b'old\n')
        merge.apply_all(self.target,changes,self.root/'backup')
        self.assertEqual((self.root/'backup/sample.txt').read_bytes(),b'old\n')
        _,rows,changes=merge.plan(self.packet,self.target)
        self.assertEqual(rows[0]['state'],'alreadyApplied');self.assertEqual(changes,[])

    def test_addition(self):
        self.make(None,b'added\n')
        _,_,changes=merge.plan(self.packet,self.target)
        merge.apply_all(self.target,changes,self.root/'backup')
        self.assertEqual((self.target/'sample.txt').read_bytes(),b'added\n')

    def test_deletion_preserves_local_edits(self):
        self.make(b'old\n',None,b'user change\n')
        _,rows,changes=merge.plan(self.packet,self.target)
        self.assertEqual(rows[0]['state'],'conflict');self.assertEqual(changes,[])

    def test_clean_three_way(self):
        self.make(b'first\nmiddle\nlast\n',b'FIRST\nmiddle\nlast\n',b'first\nmiddle\nLAST\n')
        _,rows,changes=merge.plan(self.packet,self.target,allow_merge=True)
        self.assertEqual(rows[0]['state'],'merged')
        self.assertEqual(changes[0][2],b'FIRST\nmiddle\nLAST\n')

    def test_conflicting_three_way(self):
        self.make(b'base\n',b'ours\n',b'user\n')
        review=self.root/'review'
        _,rows,changes=merge.plan(self.packet,self.target,allow_merge=True,review=review)
        self.assertEqual(rows[0]['state'],'conflict');self.assertEqual(changes,[])
        self.assertIn(b'UPLOADED_BASE',(review/'sample.txt.merge').read_bytes())
        self.assertEqual((self.target/'sample.txt').read_bytes(),b'user\n')

    def test_generated_requires_option(self):
        self.make(b'old\n',b'new\n',category='generated')
        _,rows,changes=merge.plan(self.packet,self.target)
        self.assertEqual(rows[0]['state'],'generatedSkipped');self.assertEqual(changes,[])
        _,rows,_=merge.plan(self.packet,self.target,include_generated=True)
        self.assertEqual(rows[0]['state'],'ready')

    def test_tampered_packet_and_symlink(self):
        self.make(b'old\n',b'new\n')
        (self.new/'sample.txt').write_bytes(b'tampered\n')
        with self.assertRaises(ValueError):merge.plan(self.packet,self.target)
        (self.new/'sample.txt').write_bytes(b'new\n')
        (self.target/'sample.txt').unlink()
        (self.target/'sample.txt').symlink_to(self.new/'sample.txt')
        with self.assertRaises(ValueError):merge.plan(self.packet,self.target)

    def test_edit_between_plan_and_apply(self):
        self.make(b'old\n',b'new\n')
        _,_,changes=merge.plan(self.packet,self.target)
        (self.target/'sample.txt').write_bytes(b'new user change\n')
        with self.assertRaises(RuntimeError):merge.apply_all(self.target,changes,self.root/'backup')
        self.assertEqual((self.target/'sample.txt').read_bytes(),b'new user change\n')


if __name__=='__main__':unittest.main(verbosity=2)
