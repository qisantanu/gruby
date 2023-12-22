package main

import (
	"github.com/DavidHuie/quartz/go/quartz"
	"github.com/schollz/progressbar/v3"

	// "syreclabs.com/go/faker"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
)

type Resolver struct{}

type Args struct {
	A int
}

type Response struct {
	Success   string
	StartTime int64
	EndTime   int64
}

type Adder struct{}

func (t *Resolver) FileGenerate(args Args, response *Response) error {
	n := args.A

	if _, err := os.Stat("samples/test_with_go.txt"); err == nil {
		os.Remove("samples/test_with_go.txt")
	}
	startTime := time.Now().Unix()

	*response = Response{}
	response.StartTime = startTime

	//num := 0
	progressBar := progressbar.NewOptions(n,
		progressbar.OptionSetDescription("Processing"),
		progressbar.OptionSetTheme(progressbar.Theme{Saucer: "#", SaucerPadding: ".", BarStart: "[", BarEnd: "]"}),
	)

	recordType := 'D'
	filler := ' '
	creationData := time.Now().Format("200601021504")
	header := fmt.Sprintf("H%s%s", creationData, strings.Repeat(string(filler), 210))

	file, err := os.OpenFile("samples/test_with_go.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return nil
	}
	defer file.Close()
	file.WriteString(header + "\n")

	for i := 0; i < n; i++ {
		vehicleNumber := randSeq(8)
		vehicleNumber = vehicleNumber[:8] + strings.Repeat(string(filler), 4)
		detailRecordV := string(recordType) + vehicleNumber

		obuLabel := randSeq(10)
		obuExternalPublicKey := strings.ToUpper(randSeq(182))
		vehicleRegisteredDate := time.Now().Format("20060102150405") + generateRandomDigits(3)

		detailRecord := detailRecordV + obuLabel +
			obuExternalPublicKey + vehicleRegisteredDate + strings.Repeat(string(filler), 1)

		file.WriteString(detailRecord + "\n")
		progressBar.Add(1)
	}

	file.WriteString(fmt.Sprintf("T%d%s\n", n, strings.Repeat(string(filler), 215)))
	message := " rows generated succseefully"
	concatenated := fmt.Sprint(n, message)
	fmt.Println(concatenated)
	response.Success = concatenated
	response.EndTime = time.Now().Unix()
	return nil
}

type AddArgs struct {
	A int
	B int
}

type AddResponse struct {
	Sum int
}

func (t *Adder) Add(args AddArgs, response *AddResponse) error {
	num := args.A + args.B

	*response = AddResponse{Sum: num}
	return nil
}

// Ruby end access:
// client = Quartz::Client.new(bin_path: Rails.root.join('go_scripts', 'populate_sample_file').to_s)
// client[:resolver].call('FileGenerate', 'A'=> 50000)

func main() {
	/* === This is the portion of the RPC server === */
	resolver := &Resolver{}
	quartz.RegisterName("resolver", resolver)
	my_adder_resolver := &Adder{}
	quartz.RegisterName("my_adder", my_adder_resolver)
	fmt.Println("RPC server started")
	quartz.Start()

	/* === This is the portion of the main filegenerate function === */
	//num := Args{ A: 10 }
	//myAdder.FileGenerate(num)
}

func generateRandomDigits(n int) string {
	rand.Seed(time.Now().UnixNano())
	digits := make([]byte, n)
	for i := 0; i < n; i++ {
		digits[i] = byte(rand.Intn(10) + '0')
	}
	return string(digits)
}

var letters = []rune("abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ")

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return strings.ToUpper(string(b))
}
