package device

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"strconv"
	"strings"
	"time"

	"github.com/hashicorp/nomad/helper/uuid"
	"github.com/hashicorp/nomad/plugins/device"
	"github.com/hashicorp/nomad/plugins/shared/structs"
)

// doFingerprint is the long-running goroutine that detects device changes
func (d *InkyPHatPlugin) doFingerprint(ctx context.Context, devices chan *device.FingerprintResponse) {
	defer close(devices)

	// Create a timer that will fire immediately for the first detection
	ticker := time.NewTimer(0)

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			ticker.Reset(30*time.Second)
			devices <- d.buildFingerprint()
		}
	}
}

var (
	ID = uuid.Generate()
)

func (d *InkyPHatPlugin) buildFingerprint() *device.FingerprintResponse {

	d.deviceLock.Lock()
	defer d.deviceLock.Unlock()

	width, height, color, err := inkyphatStatus()
	if err != nil {
		return &device.FingerprintResponse{
			Error: err,
		}
	}

	if width == 0 || height == 0 || color == "" {
		return nil
	}

	discovered := &DiscoveredInkyPhat{
		width:  int64(width),
		height: int64(height),
		color:  color,
	}

	d.devices[ID] = discovered

	deviceGroups := []*device.DeviceGroup{
		{
			Vendor:     "pimoroni",
			Type:       "epaper",
			Name:       "inkyphat",
			Devices:    []*device.Device{
				{
					ID:         ID,
					Healthy:    true,
					HealthDesc: "",
					HwLocality: nil,
				},
			},
			Attributes: map[string]*structs.Attribute{
				"width": {Int: &discovered.width},
				"height": {Int: &discovered.height},
				"color": {String: &color},
			},
		},
	}
	return device.NewFingerprint(deviceGroups...)
}

func inkyphatStatus() (width, height int, color string, err error) {
	var out bytes.Buffer

	cmd := exec.Command("inkyphat-stats")
	cmd.Stdout = &out
	cmd.Stderr = &out
	err = cmd.Run()
	if err != nil {
		err = fmt.Errorf("failed to determine inkyphat stats: %v", err)
		return
	}

	width, height, color = parseInkyPHatStatus(out.String())
	return
}

func parseInkyPHatStatus(infoString string) (width, height int, color string) {
	lines := strings.Split(infoString, "\n")
	for _, line := range lines {
		if split := strings.Split(line, ":"); len(split) == 2 {
			switch key := strings.TrimSpace(split[0]); key {
			case "width", "height":
				if i, err := strconv.Atoi(strings.TrimSpace(split[1])); err == nil {
					if key == "width" {
						width = i
					} else {
						height = i
					}
				}
			case "color":
				color = strings.TrimSpace(split[1])
			}
		}
	}
	return
}
