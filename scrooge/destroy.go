package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"syscall"
)

func Destroy(project, workspace string, resources []string) error {
	args := []string{project, workspace}
	for _, res := range resources {
		args = append(args, fmt.Sprintf("-target=%s", res))
	}

	_, err := Exec("destroy", args, nil, true)
	if err != nil {
		return err
	}

	return nil
}

func createProject(project, workspace string) (string, error) {
	projDir := fmt.Sprintf("%s:%s:*", project, workspace)
	dir, err := os.MkdirTemp("", projDir)
	if err != nil {
		return "", err
	}

	input, err := os.ReadFile("/projects/main.tf")
	if err != nil {
		return "", err
	}
	err = os.WriteFile(fmt.Sprintf("%s/main.tf", dir), input, 0666)
	if err != nil {
		return "", err
	}

	return projDir, nil
}

func Exec(bin string, args []string, envs []string, isStdout bool) (string, error) {
	binary, err := exec.LookPath(bin)
	if err != nil {
		return "", fmt.Errorf("couldn't find %s executable. Make sure %s is installed", bin, bin)
	}

	cmd := exec.Command(binary, args...)
	if envs != nil {
		cmd.Env = append(cmd.Env, envs...)
	}

	stdout, _ := cmd.StdoutPipe()
	stderr := new(strings.Builder)
	output := new(strings.Builder)
	cmd.Stderr = stderr

	if err = cmd.Start(); err != nil {
		return "", err
	}

	scanner := bufio.NewScanner(stdout)
	scanner.Split(bufio.ScanLines)
	for scanner.Scan() {
		m := scanner.Text()
		output.WriteString(m)
		output.WriteString("\n")
		if isStdout {
			fmt.Println(m)
		}
	}

	if err := cmd.Wait(); err != nil {
		if ext, ok := err.(*exec.ExitError); ok {
			if _, ok := ext.Sys().(syscall.WaitStatus); ok {
				return "", fmt.Errorf(stderr.String())
			}
		} else {
			return "", err
		}
	}

	return output.String(), nil
}
