// package main

// import (
// 	"github.com/DavidHuie/quartz/go/quartz"
//     "fmt"
// )

// type Adder struct{}

// type Args struct {
//     A int
//     B int
// }

// type Response struct {
//     Sum int
// }

// func (t *Adder) Add(args Args, response *Response) error {
//     *response = Response{args.A + args.B}
//     return nil
// }

// func main() {
// 	myAdder := &Adder{}
// 	quartz.RegisterName("my_adder", myAdder)
//     fmt.Println("Hello RPC")
// 	quartz.Start()
// }
