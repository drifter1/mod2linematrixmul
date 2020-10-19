# mod2linematrixmul
VHDL Implementation of Modulo2 Line by Matrix Multiplication (with Tutorial Series on Steemit)

# Articles
- https://steemit.com/programming/@drifter1/logic-design-implementing-modulo2-multiplication-of-line-with-matrix-in-vhdl-part1
  - explaining the problem
  - analyzing it
  - creating a software model (c-code)
  - setting up an architecture that can solve it in hardware
- https://steemit.com/programming/@drifter1/logic-design-implementing-modulo2-multiplication-of-line-with-matrix-in-vhdl-part2
  - explaining how our architecture works
  - splitting the implementation in steps
  - implementing the storage step of vector A (step 1)
- https://steemit.com/programming/@drifter1/logic-design-implementing-modulo2-multiplication-of-line-with-matrix-in-vhdl-part3
  - implementing the calculation step of the result vector R (step 2)
- https://steemit.com/programming/@drifter1/logic-design-implementing-modulo2-multiplication-of-line-with-matrix-in-vhdl-part4
  - implementing the FSM as a component (step 3)
  - writing a testbench 
 
 # Hardware Architecture
 ![Modulo 2 Line by Matrix Multiplication](https://steemitimages.com/640x0/https://s8.postimg.cc/ee284izhx/diagram_main.jpg)
 
 ![Modulo 2 Line by Matrix Multiplication: Processing Unit](https://steemitimages.com/640x0/https://s8.postimg.cc/obd8xlu91/processing_unit.jpg)
 
 ![Modulo 2 Line by Matrix Multiplication: FSM](https://steemitimages.com/640x0/https://s8.postimg.cc/569znu05h/fsm.jpg)
