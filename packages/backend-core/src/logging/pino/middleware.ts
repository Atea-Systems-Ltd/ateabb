import env from "../../environment"
import { IncomingMessage } from "http"
import type { Options } from "pino-http"
import { Ctx } from "@budibase/types"

const pino = require("koa-pino-logger")
const correlator = require("correlation-id")

export function pinoSettings(): Options {
  // Intentionally NOT passing a custom `logger` to avoid type collisions.
  return {
    genReqId: correlator.getId,
    autoLogging: {
      ignore: (req: IncomingMessage) => !!req.url?.includes("/health"),
    },
    serializers: {
      req: (req: any) => {
        return {
          method: req.method,
          url: req.url,
          // `id` is attached by pino-http at runtime
          correlationId: req.id,
        }
      },
      res: (res: any) => {
        return {
          status: res.statusCode,
        }
      },
    },
  }
}

function getMiddleware() {
  if (env.HTTP_LOGGING) {
    return pino(pinoSettings())
  } else {
    return (ctx: Ctx, next: any) => {
      return next()
    }
  }
}

const pinoMiddleware = getMiddleware()

export default pinoMiddleware

