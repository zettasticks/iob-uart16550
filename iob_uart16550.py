#!/usr/bin/env python3

import os
import sys

from iob_module import iob_module
from setup import setup

# Submodules
from iob_lib import iob_lib
from iob_utils import iob_utils
from iob_clkenrst_portmap import iob_clkenrst_portmap
from iob_clkenrst_port import iob_clkenrst_port
from iob_iob2wishbone import iob_iob2wishbone
from iob_wishbone2iob import iob_wishbone2iob

class iob_uart16550(iob_module):
    name = "iob_uart16550"
    version = "V0.10"
    flows = "sim emb"
    setup_dir=os.path.dirname(__file__)

    @classmethod
    def _run_setup(cls):
        # Hardware headers & modules
        iob_module.generate("iob_s_port")
        iob_module.generate("iob_s_portmap")
        iob_module.generate("iob_wire")
        iob_lib.setup()
        iob_utils.setup()
        iob_clkenrst_portmap.setup()
        iob_clkenrst_port.setup()
        iob_iob2wishbone.setup()
        iob_wishbone2iob.setup()

        cls._setup_confs()
        cls._setup_ios()
        cls._setup_regs()
        cls._setup_block_groups()

        # Verilog modules instances
        # TODO

        # Copy sources of this module to the build directory
        super()._run_setup()

        # Setup core using LIB function
        setup(cls)


    @classmethod
    def _setup_confs(cls):
        super()._setup_confs([
            # Macros

            # Parameters
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "16",
                "min": "NA",
                "max": "NA",
                "descr": "Address bus width",
            },
            # Used for regs below
            {
                "name": "UART_DATA_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "8",
                "descr": "",
            },
        ])

    @classmethod
    def _setup_ios(cls):
        cls.ios += [
            {"name": "iob_s_port", "descr": "CPU native interface", "ports": []},
            {
                "name": "general",
                "descr": "GENERAL INTERFACE SIGNALS",
                "ports": [
                    {
                        "name": "clk_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System clock input",
                    },
                    {
                        "name": "arst_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, asynchronous and active high",
                    },
                    {
                        "name": "cke_i",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "System reset, asynchronous and active high",
                    },
                ],
            },
            {
                "name": "rs232",
                "descr": "UART16550 rs232 interface signals.",
                "ports": [
                    # {'name':'interrupt', 'type':'O', 'n_bits':'1', 'descr':'be done'},
                    {
                        "name": "txd",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Serial transmit line",
                    },
                    {"name": "rxd", "type": "I", "n_bits": "1", "descr": "Serial receive line"},
                    {
                        "name": "cts",
                        "type": "I",
                        "n_bits": "1",
                        "descr": "Clear to send; the destination is ready to receive a transmission sent by the UART",
                    },
                    {
                        "name": "rts",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "Ready to send; the UART is ready to receive a transmission from the sender",
                    },
                ],
            },
            {
                "name": "interrupt",
                "descr": "UART16550 interrupt related signals",
                "ports": [
                    {
                        "name": "interrupt",
                        "type": "O",
                        "n_bits": "1",
                        "descr": "UART interrupt source",
                    },
                ],
            },
        ]

    @classmethod
    def _setup_regs(cls):
        cls.regs += [
            {
                "name": "uart",
                "descr": "UART software accessible registers.",
                "regs": [
                    {
                        "name": "SOFTRESET",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Soft reset.",
                    },
                    {
                        "name": "DIV",
                        "type": "W",
                        "n_bits": 16,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "Bit duration in system clock cycles.",
                    },
                    {
                        "name": "TXDATA",
                        "type": "W",
                        "n_bits": "UART_DATA_W",
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "TX data.",
                    },
                    {
                        "name": "TXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "TX enable.",
                    },
                    {
                        "name": "RXEN",
                        "type": "W",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": 6,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "RX enable.",
                    },
                    {
                        "name": "TXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "TX ready to receive data.",
                    },
                    {
                        "name": "RXREADY",
                        "type": "R",
                        "n_bits": 1,
                        "rst_val": 0,
                        "addr": -1,
                        "log2n_items": 0,
                        "autologic": True,
                        "descr": "RX data is ready to be read.",
                    },
                    {
                        "name": "RXDATA",
                        "type": "R",
                        "n_bits": "UART_DATA_W",
                        "rst_val": 0,
                        "addr": 4,
                        "log2n_items": 0,
                        "autologic": False,
                        "descr": "RX data.",
                    },
                ],
            }
        ]

    @classmethod
    def _setup_block_groups(cls):
        cls.block_groups += []
