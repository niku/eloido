provider "arukas" {
  # You have to set following environment variables:
  # ARUKAS_JSON_API_TOKEN : Your Arukas API token
  # ARUKAS_JSON_API_SECRET: Your Arukas API secret
}

variable "twitter_consumer_key" {}
variable "twitter_consumer_secret" {}
variable "twitter_access_token" {}
variable "twitter_access_secret" {}
variable "idobata_webhook" {}
variable "track" {
  default = "サッポロビーム,sapporobeam,sapporo-beam,sapporo.beam"
}
variable "follow" {
  default = "507309896"
}

resource "arukas_container" "eloido" {
  name      = "eloido"
  image     = "niku/eloido"
  instances = 1
  memory    = 256

  ports = {
    protocol = "tcp"
    number   = "4000"
  }

  cmd = "mix run --no-halt"

  environments {
    key   = "TWITTER_CONSUMER_KEY"
    value = "${var.twitter_consumer_key}"
  }

  environments {
    key   = "TWITTER_CONSUMER_SECRET"
    value = "${var.twitter_consumer_secret}"
  }

  environments {
    key   = "TWITTER_ACCESS_TOKEN"
    value = "${var.twitter_access_token}"
  }

  environments {
    key   = "TWITTER_ACCESS_SECRET"
    value = "${var.twitter_access_secret}"
  }

  environments {
    key   = "IDOBATA_WEBHOOK"
    value = "${var.idobata_webhook}"
  }

  environments {
    key   = "TRACK"
    value = "${var.track}"
  }

  environments {
    key   = "FOLLOW"
    value = "${var.follow}"
  }
}
