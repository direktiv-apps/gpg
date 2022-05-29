package main

import (
	"fmt"
	"log"
	"math/big"
	"os"
	"os/exec"
)

const (
	// pid file shared across calls
	pidFile = "/tmp/agent.pid"
)

func main() {

	fmt.Println("checking pgp agent")

	pidB, err := os.ReadFile(pidFile)

	// pid file does not exist
	if err != nil {
		fmt.Printf("error reading pid file: %v\n", err)
		startAgent()
		return
	}

	pid := int(big.NewInt(0).SetBytes(pidB).Uint64())
	fmt.Printf("checking pid %d\n", pid)

	// process is dead restart
	_, err = os.FindProcess(pid)
	if err != nil {
		fmt.Printf("error finding process: %v\n", err)
		startAgent()
	}

}

func startAgent() {
	os.Remove(pidFile)

	fmt.Println("starting gpg agent.")
	cmd := exec.Command("gpg-agent", "--daemon")
	err := cmd.Run()

	// we can die
	if err != nil {
		log.Fatalf("can not start pgp-agent: %v", err)
	}

	f, err := os.Create(pidFile)
	if err != nil {
		log.Fatalf("can not create pid file: %v", err)
	}
	defer f.Close()

	_, err = f.Write([]byte(fmt.Sprintf("%d", cmd.Process.Pid)))
	if err != nil {
		log.Fatalf("can not write to pid file: %v", err)
	}

	fmt.Printf("started agent with pid %v\n", cmd.Process.Pid)
}
