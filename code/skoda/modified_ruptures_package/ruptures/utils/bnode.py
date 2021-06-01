"""Binary node."""


class Bnode:

    """Binary node.

    In binary segmentation, each segment [start, end) is a binary node.

    """

    def __init__(self, start, end, val, left=None, right=None, parent=None):
        self.start = start
        self.end = end
        self.val = val
        self.left = left
        self.right = right
        self.parent = parent

    @property
    def gain(self):
        """Return the cost decrease when splitting this node."""
        if self.left is None or self.right is None:
            return 0
        elif abs(self.val) < 1e-8:
            return 0
        return self.val - (self.left.val + self.right.val)