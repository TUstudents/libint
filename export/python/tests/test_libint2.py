import unittest
import libint2
from numpy.linalg import norm

from libint2 import Shell, BasisSet

libint2.Engine.num_threads = 1

s = Shell(0, [(1,10)])
p = Shell(1, [(1,10)])
d = Shell(2, [(1,10)], [0.1, 0.2, 0.3])

h2o = [
  (8, [  0.00000, -0.07579, 0.00000 ]),
  (1, [  0.86681,  0.60144, 0.00000 ]),
  (1, [ -0.86681,  0.60144, 0.00000 ]),
]

class TestLibint(unittest.TestCase):

  def test_core(self):
    self.assertTrue(libint2.MAX_AM > 0)    

    basis = BasisSet('6-31g', h2o)
    self.assertEqual(len(basis), 9)
    basis.pure = False
    pure = [False]*len(basis)
    self.assertEqual([ s.pure for s in basis], pure)
    basis[0].pure = True
    pure[0] = True
    self.assertEqual([ s.pure for s in basis], pure)
  
  def test_integrals(self):
    self.assertAlmostEqual(norm(libint2.kinetic().compute(s,s)), 1.5)
    self.assertAlmostEqual(norm(libint2.overlap().compute(s,s)), 1.0)
    self.assertAlmostEqual(norm(libint2.nuclear(h2o).compute(s,s)), 14.54704336519)

    self.assertAlmostEqual(norm(libint2.coulomb().compute(p,p,s,s)), 1.62867503968)

    self.assertAlmostEqual(
      norm(libint2.Engine(libint2.Operator.coulomb, braket=libint2.BraKet.XXXS).compute(s,s,s)),
      3.6563211198
    )

    if libint2.solid_harmonics_ordering() == libint2.SHGShellOrdering.Standard:
        basis = [ p, d ]
        S = libint2.overlap().compute(basis, basis)
        self.assertAlmostEqual(S[0, 3], -0.08950980671097111)
        self.assertAlmostEqual(S[0, 4], -0.26852942)
        self.assertAlmostEqual(S[1, 3], 0.0055943629194356937)

if __name__ == '__main__':
  unittest.main()
