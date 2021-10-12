import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { connect } from "./redux/blockchain/blockchainActions";
import { fetchData } from "./redux/data/dataActions";
import store from './redux/store';
import * as s from "./styles/globalStyles";
import styled from "styled-components";
import i1 from "./assets/images/example.png";
import g1 from "./assets/images/art_5.gif"
import tl from "./assets/images/twitter.png"
import dl from "./assets/images/discord.png"


export const StyledButton = styled.button`
  padding: 10px;
  border-radius: 10px;
  border: none;
  background-color: #68228e;
  padding: 10px;
  font-weight: bold;
  color: #ffffff;
  width: 250px;
  cursor: pointer;
  box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -webkit-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  -moz-box-shadow: 0px 6px 0px -2px rgba(250, 250, 250, 0.3);
  :active {
    box-shadow: none;
    -webkit-box-shadow: none;
    -moz-box-shadow: none;
  }
`;

export const ResponsiveWrapper = styled.div`
  display: flex;
  flex: 1;
  flex-direction: column;
  justify-content: stretched;
  align-items: stretched;
  width: 60%;
  @media (min-width: 767px) {
    flex-direction: row;
  }
`;

export const StyledImg = styled.img`
  width: 200px;
  height: 200px;
  @media (min-width: 767px) {
    width: 500px;
    height: 500px;
  }
  transition: width 0.5s;
  transition: height 0.5s;
`;

export const StyledRow = styled.div`
  display:inline-block;
`;


function App() {
  const dispatch = useDispatch();
  const blockchain = useSelector((state) => state.blockchain);
  const data = useSelector((state) => state.data);
  const [feedback, setFeedback] = useState("Join the Euphoric NFT Revolution");
  const [claimingNft, setClaimingNft] = useState(false);
  const [val, setVal] = useState('');
// const [checkWhitelist, setCheckWhitelist] = useState(false);
  
  ///////////////////////////////// Count down function (ED)
  
  const calculateTimeLeft = () => {
    let difference = +new Date(`10/11/2021`).setHours(new Date().getHours() + 6) - +new Date();
    let timeLeft = {};

    if (difference > 0) {
      timeLeft = {
        days: Math.floor(difference / (1000 * 60 * 60 * 24)),
        hours: Math.floor((difference / (1000 * 60 * 60)) % 24),
        minutes: Math.floor((difference / 1000 / 60) % 60),
        seconds: Math.floor((difference / 1000) % 60)
    };
  }
  return timeLeft;
  }

  const [timeLeft, setTimeLeft] = useState(calculateTimeLeft());

  useEffect(() => {
    const timer = setTimeout(() => {
      setTimeLeft(calculateTimeLeft());
    }, 1000);
  });

  const timerComponents = [];

  Object.keys(timeLeft).forEach((interval) => {
    if (!timeLeft[interval]) {
      return;
    }
  
    timerComponents.push(
      <span>
        {timeLeft[interval]} {interval}{" "}
      </span>
    );
  });

  ///////////////////////////////////// Check if on whitelist function

  // const checkWhitelist = (_address) => {
  //   setCheckWhitelist(true);
  //   blockchain.smartContract.methods
  //   .checkWhitelist(blockchain.account)
  // }

  /////////////////////////////////////

  const claimNFTs = (_amount) => {
    if (_amount <= 0) {
      return;
    }
    setFeedback("Minting your EuphorAI...");
    setClaimingNft(true);
    blockchain.smartContract.methods
      .mintNFTs(_amount)
      .send({
        gasLimit: "285000",
        to: "0x2D45ca961b6915AcF2F88064e542e37Ca4cF9192", 
        from: blockchain.account,
        value: blockchain.web3.utils.toWei((.01 * _amount).toString(), "ether"),
      })
      .once("error", (err) => {
        console.log(err);
        setFeedback("Sorry, something went wrong please try again later. (Did you try to mint too many?)");
        setClaimingNft(false);
      })
      .then((receipt) => {
        setFeedback(
          "You now own a EuphorAI! go visit Opensea.io to view it."
        );
        setClaimingNft(false);
        dispatch(fetchData(blockchain.account));
      });
  };

  const getData = () => {
    if (blockchain.account !== "" && blockchain.smartContract !== null) {
      dispatch(fetchData(blockchain.account));
    }
  };

  useEffect(() => {
    getData();
  }, [blockchain.account]);

  return (
    <s.Screen style={{ backgroundColor: "var(--white)" }}>
      <s.Container flex={1} ai={"center"} style={{ padding: 58 }}>
        <s.TextTitle
          style={{ textAlign: "center", fontSize: 36, fontWeight: "bold" }}
        >
          Welcome to EuphorAI
        </s.TextTitle>
        <s.SpacerSmall />
          <div>
          <a href="https://twitter.com/EuphorAI_NFT">
            <img src={tl} width="50" height="50"/>
          </a>
          <spacer type="horizontal"> </spacer>
          <a href="https://discord.gg/vtwHpSTZ">
            <img src={dl} width="50" height="50"/>
          </a>
          </div>
        <s.SpacerSmall />
        <ResponsiveWrapper flex={1} style={{ padding: 24 }}>
          <s.Container flex={1} jc={"center"} ai={"center"}>
            <StyledImg alt={"example"} src={i1} />
            <s.SpacerMedium />
            <s.TextTitle
              style={{ textAlign: "center", fontSize: 26, fontWeight: "bold" }}
            >
              {data.totalSupply}/5000
            </s.TextTitle>
            </s.Container>
          <s.SpacerMedium />
          <s.Container
            flex={1}
            jc={"center"}
            ai={"center"}
            style={{ padding: 36 }}
          >
            {Number(data.totalSupply) == 5000 ? (
              <>
                <s.TextTitle style={{ textAlign: "center" }}>
                  The sale has ended.
                </s.TextTitle>
                <s.SpacerSmall />
                <s.TextDescription style={{ textAlign: "center" }}>
                  You can still find EuphorAI's on{" "}
                  <a
                    target={"_blank"}
                    href={"https://opensea.io/collection/euphorai"}
                  >
                    Opensea.io
                  </a>
                </s.TextDescription>
              </>
            ) : (
              <>
                <s.TextTitle style={{ textAlign: "center", fontSize: 24 }}>
                  1 EUPH costs 0.05 ETH.
                </s.TextTitle>
                <s.SpacerXSmall />
                <s.TextDescription style={{ textAlign: "center", fontSize: 12 }}>
                  Excluding gas fee.
                </s.TextDescription>
                <s.SpacerSmall />
                <s.TextDescription style={{ textAlign: "center", fontSize: 16}}>
                  {feedback}
                </s.TextDescription>
                <s.SpacerSmall />
                {blockchain.account === "" ||
                blockchain.smartContract === null ? (
                  <s.Container ai={"center"} jc={"center"}>
                    <StyledButton
                      onClick={(e) => {
                        e.preventDefault();
                        dispatch(connect());
                        getData();
                      }}
                    >
                      CONNECT TO METAMASK
                    </StyledButton>
                    {blockchain.errorMsg !== "" ? (
                      <>
                        <s.SpacerSmall />
                        <s.TextDescription style={{ textAlign: "center" , fontSize: 24}}>
                          {blockchain.errorMsg}
                        </s.TextDescription>
                      </>
                    ) : null}
                  </s.Container>
                ) : (
                  <s.Container ai={"center"} jc={"center"} fd={"row"}>
                    <div align="center">
                    <form>
                      <input
                      max="10"
                      size="16"
                      type="number" 
                      name="mintNum"
                      placeholder="How many? Max 10"
                      onChange={e => setVal(e.target.value)} />
                    </form>
                    <s.SpacerSmall/>
                    <>
                    </>
                    <StyledButton
                      disabled={claimingNft ? 1 : 0} // We need to maybe add something to not let people try more than 10 or it will fail
                      onClick={(e) => {
                        e.preventDefault();
                        claimNFTs(val);
                        getData();
                      }}
                    >
                      {claimingNft ? "BUSY" : "MINT"}
                    </StyledButton>
                    </div>
                  </s.Container>
                )}
              </>
            )}
          </s.Container>
        </ResponsiveWrapper>
        <s.SpacerSmall />
        <s.Container jc={"center"} ai={"center"} style={{ width: "50%" }}>
          <s.TextDescription style={{ textAlign: "center", fontSize: 16 }}>
          EuphorAI NFTs are generated by using a neural network based on hyperbolic tangets using random seeds to generate art with
          varying colors, depth and layers. The collection explores various states of euphoria and each piece is completely one-of-a-kind!  
          After you mint, check out your piece on Opensea.io for rarity unique attributes. 
          This is only the beginning – roadmap for future releases, exclusive collections, 
          community driven incentives and much more COMING SOON! 
          </s.TextDescription>
        </s.Container>
        <s.SpacerSmall />
        <s.TextTitle style={{ textAlign: "center", fontSize: 24, fontWeight: "bold" }}>
           Future of EuphorAI 
        </s.TextTitle>
        <s.Container jc={"center"} ai={"center"} style={{ width: "50%" }}>
        <s.SpacerSmall />
          <s.TextSubTitle style={{textAlign: "center", fontSize: 16}}>
          Phase 1 on our roadmap is the release of The "Euphoria Collection". 
          Once all pieces are minted the next iteration of the project will commence.
          The "Dysphoria Collection" will allow users who own a piece for the "Euphoria Collection" 
          to mint a new dynamic, gif NFT version of their art by combining two NFTs from the "Euphoria Collection".
          </s.TextSubTitle>
        <s.SpacerSmall />
          <img src={g1} width="250" height="250"/>
        </s.Container>
        
        <s.SpacerLarge />
        <s.Container jc={"center"} ai={"center"} style={{ width: "70%" }}>
          <s.SpacerSmall />
          <s.TextDescription style={{ textAlign: "center", fontSize: 10 }}>
            Please make sure you are connected to the right network (Ethereum
            Mainnet) and the correct address. Please note: Once you make the
            purchase, you cannot undo this action.
          </s.TextDescription>
          <s.SpacerSmall />
          <s.TextDescription style={{ textAlign: "center", fontSize: 10 }}>
            We have set the gas limit to 285000 for the contract to successfully
            mint your NFT. We recommend that you don't change the gas limit.
          </s.TextDescription>
        </s.Container>
      </s.Container>
    </s.Screen>
  );
}

export default App;

