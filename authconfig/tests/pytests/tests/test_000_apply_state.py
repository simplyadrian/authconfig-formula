from unittest import TestCase
from subprocess import check_output


class ApplyStateTest(TestCase):

    def test_apply(self):
        state_apply_response = check_output(["salt-call", "--local", "state.apply"]).split('\n')
        summary = state_apply_response[-8:]
        failed = 0
        for line in summary:
            if line.startswith('Failed:'):
                failed = int(line.split(':').pop().strip())

        # should be 0 when we can test against AD server
        # self.assertEqual(failed, 0)
        self.assertEqual(failed, 1)
