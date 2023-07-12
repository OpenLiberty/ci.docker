package main_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"context"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/containers/podman/v4/pkg/bindings"
	"github.com/containers/podman/v4/pkg/bindings/containers"
	"github.com/containers/podman/v4/pkg/bindings/images"
	"github.com/containers/podman/v4/pkg/domain/entities"
	"github.com/containers/podman/v4/pkg/specgen"
)

func TestTest(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Test Suite")
}

var _ = Describe("Open Liberty container images", func() {
	// Set CONTAINER_HOST and CONTAINER_SSHKEY environment variables beforehand
	Context("kernel-slim images", func() {
		var imageDir string = "../releases/latest/kernel-slim"
		BeforeEach(func() {
			conn, err := bindings.NewConnectionWithIdentity(context.Background(), "", "", true)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			// Prune existing containers
			if _, err := containers.Prune(conn, nil); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
		})

		It("can build an UBI image and run spring-petclinic", func() {
			var baseImage string = "open-liberty-test:kernel-slim-ubi-openjdk17"
			var petClinicImage string = "open-liberty-test:kernel-slim-ubi-petclinic"
			var petClinicImageName string = "petclinic"
			conn, err := bindings.NewConnectionWithIdentity(context.Background(), "", "", true)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			// Build a kernel-slim image from scratch
			containerFiles := []string{imageDir + "/Dockerfile.ubi.openjdk17"}
			// Check the full list of BuildOptions from https://github.com/containers/buildah/blob/aa6a281df7c54aa42a060baa9d0504040c7551a6/define/build.go#L112
			buildOptions := entities.BuildOptions{}
			buildOptions.ContextDirectory = imageDir
			// Override the default image to pull a locally built image each time
			buildOptions.Output = baseImage
			_, err = images.Build(conn, containerFiles, buildOptions)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			// Build the petclinic image from kernel-slim
			containerFiles = []string{"../samples/spring-petclinic/Dockerfile"}
			buildOptions = entities.BuildOptions{}
			buildOptions.ContextDirectory = "../samples/spring-petclinic/"
			// Override the default image to pull a locally built image each time
			buildOptions.Args = map[string]string{"IMAGE": baseImage}
			buildOptions.Output = petClinicImage
			_, err = images.Build(conn, containerFiles, buildOptions)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			s := specgen.NewSpecGenerator(petClinicImage, false)
			s.Name = petClinicImageName
			createResponse, err := containers.CreateWithSpec(conn, s, nil)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			if err := containers.Start(conn, createResponse.ID, nil); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			// Wait for server to load
			time.Sleep(10 * time.Second)

			stdoutChan := make(chan string)
			stderrChan := make(chan string)
			go containers.Logs(conn, createResponse.ID, nil, stdoutChan, stderrChan)
			maxReads := 1000
			needles := []string{"The petclinic server is ready to run a smarter planet."}
			found := []bool{false}
			for i := 0; i < maxReads; i++ {
				select {
				case line := <-stdoutChan:
					for j, val := range found {
						if !val && j < len(needles) {
							if strings.Contains(line, needles[j]) {
								found[j] = true
							}
						}
					}
				default:
				}
				time.Sleep(10 * time.Millisecond)
			}
			if err := containers.Stop(conn, petClinicImageName, nil); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			Expect(found[0]).To(Equal(true))
		})

		It("can build an Ubuntu image and run spring-petclinic", func() {
			var baseImage string = "open-liberty-test:kernel-slim-ubuntu-openjdk17"
			var petClinicImage string = "open-liberty-test:kernel-slim-ubuntu-petclinic"
			var petClinicImageName string = "petclinic"
			conn, err := bindings.NewConnectionWithIdentity(context.Background(), "", "", true)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			// Build a kernel-slim image from scratch
			containerFiles := []string{imageDir + "/Dockerfile.ubuntu.openjdk17"}
			// Check the full list of BuildOptions from https://github.com/containers/buildah/blob/aa6a281df7c54aa42a060baa9d0504040c7551a6/define/build.go#L112
			buildOptions := entities.BuildOptions{}
			buildOptions.ContextDirectory = imageDir
			// Override the default image to pull a locally built image each time
			buildOptions.Output = baseImage
			_, err = images.Build(conn, containerFiles, buildOptions)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			// Build the petclinic image from kernel-slim
			containerFiles = []string{"../samples/spring-petclinic/Dockerfile"}
			buildOptions = entities.BuildOptions{}
			buildOptions.ContextDirectory = "../samples/spring-petclinic/"
			// Override the default image to pull a locally built image each time
			buildOptions.Args = map[string]string{"IMAGE": baseImage}
			buildOptions.Output = petClinicImage
			_, err = images.Build(conn, containerFiles, buildOptions)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}

			s := specgen.NewSpecGenerator(petClinicImage, false)
			s.Name = petClinicImageName
			createResponse, err := containers.CreateWithSpec(conn, s, nil)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			if err := containers.Start(conn, createResponse.ID, nil); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			// Wait for server to load
			time.Sleep(10 * time.Second)

			stdoutChan := make(chan string)
			stderrChan := make(chan string)
			go containers.Logs(conn, createResponse.ID, nil, stdoutChan, stderrChan)
			maxReads := 1000
			needles := []string{"The petclinic server is ready to run a smarter planet."}
			found := []bool{false}
			for i := 0; i < maxReads; i++ {
				select {
				case line := <-stdoutChan:
					for j, val := range found {
						if !val && j < len(needles) {
							if strings.Contains(line, needles[j]) {
								found[j] = true
							}
						}
					}
				default:
				}
				time.Sleep(10 * time.Millisecond)
			}
			if err := containers.Stop(conn, petClinicImageName, nil); err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			Expect(found[0]).To(Equal(true))
		})
	})
})
