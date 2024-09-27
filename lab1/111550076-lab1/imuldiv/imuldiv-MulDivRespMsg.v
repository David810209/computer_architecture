//========================================================================
// imuldiv-MulDivRespMsg : Multiplier/Divider Response Message
//========================================================================
// A multiplier/divider response message is a trivial message with just
// the result data.
//
// Message Format:
//
//   63                   0
//  +----------------------+
//  |       result         |
//  +----------------------+
//

`ifndef IMULDIV_MULDIVRESP_MSG_V
`define IMULDIV_MULDIVRESP_MSG_V

//------------------------------------------------------------------------
// Message defines
//------------------------------------------------------------------------

// Size of message

`define IMULDIV_MULDIVRESP_MSG_SZ         64

`endif /* IMULDIV_MULDIVRESP_MSG_V */

